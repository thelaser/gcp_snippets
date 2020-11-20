# Setting up IAP with GKE 

In this guide I'll cover how to deploy a simple [Docker](https://web.archive.org/web/20201112013715/https://www.zdnet.com/article/what-is-docker-and-why-is-it-so-darn-popular/) application to the Google Kubernetes Engine ([Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/), [GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview)), serve it through an [HTTPS Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) and then put [GCP's Identity Aware Proxy(IAP)](https://cloud.google.com/iap/docs/concepts-overview) in front of the app so that only users with the appropriate permissions in [IAM](https://cloud.google.com/iam/docs/overview) can access.

I will be assuming you have **access to a GCP account with an already setup project** to do all this and have already [installed the Cloud SDK](https://cloud.google.com/sdk/docs/install) in your local computer.

You will also need to **own a domain** in order to follow this guide.

<br/>

## Steps
<br/>

## Preparing

### 1. Create a domain for our example
### 2. Create a LetsEncrypt HTTPS certificate for the domain 
### 3. Create a static global IP address and firewall rules for IAP
### 4. Prepare Docker image for deployment
### 5. Setup OAuth Consent screen with domain
### 6. Create OAuth credentials and redirect page
<br/>

## Kubernetes meddling

### 7. Create cluster
### 8. Create a namespace for the environment
### 9. Create secret of HTTPS certificates and OAuth token
### 10. Create a Deployment to serve the app
### 11. Create Backend config with the OAuth secret
### 12. Create a Service referencing the Backend config
### 13. Create Ingress referencing the Service and the HTTPS certificate secret
<br/>

## Finishing

### 14. Give yourself permission to access through IAP
### 15. Troubleshooting

<br/>
<hr>

<br/>
<br/>


## 1. Create a domain for our example

A free domain registrar can be used, like Freenom. I used OVH for the domain part, as I already had some domains in there.

<br/>

## 2. Create a Let's Encrypt HTTPS certificate for the domain

Once you have the domain working with its DNS servers and all, it's time to use Let's Encrypt free certificates, and for that we can use Certbot.

I will be assuming you don't have currently any available server to do the verification when issuing the certificate, therefore I'll use the manual mode with a DNS challenge with certbot. 

The process is simple, install certbot to your machine and run it:

```
sudo apt-get update && sudo apt-get install certbot
sudo certbot --manual --preferred-challenges dns certonly -d <yourdomain>
 
# i.e. if your domain is example.com you would run
# sudo certbot --manual --preferred-challenges dns certonly -d example.com

```

The process will ask you to change the TXT register of your DNS servers to the challenge code certbot will generate. Change the record, wait a minute or two and continue the process, and that should be it for this part.

The certificates are stored in `/etc/letsencrypt/live/<domainName>/`

<br/>

## 3. Create a static global IP address and firewall rules for IAP

We don't want the IP address pointed by the DNS to be changing or doing funny stuff, so we will be assigning a static address to it. 

The name I will be giving the address **must be the same for you too**, if you want to just copy paste the whole guide:

` gcloud compute addresses create iap-gke --global `

By issuing that command an address named `iap-gke` should have been created.

We are using a global address since a GKE Ingress in external load balancer mode only accepts global addresses.

Now for the firewall rules, we need to open a specific IP block for IAP:

```
gcloud compute firewall-rules create iap-clone --allow tcp:80,tcp:443 --source-ranges 35.235.240.0/20,35.191.0.0/16,130.211.0.0/22
```

After all you have to let IAP proxy your requests, and therefore access your resources.

Another important step here is to **make the DNS servers for your domain point to the IP address we just reserved**.

<br/>


## 4. Prepare Docker image for deployment

GKE clusters need to get their Docker images from a repository in order to create Pods.
For our example we will create a Dockerfile that shows the name of the current Pod delivering our request through the proxy and load balancer. The Dockerfile should look like this:

**Dockerfile_itsame**
```
COPY nginx_default.conf /etc/nginx/conf.d/default.conf
CMD echo "<h1> Hello my name is $(hostname)!!! </h1>" > /usr/share/nginx/html/index.html; /usr/sbin/nginx -g 'daemon off;'
```

We must build the image locally from the Dockerfile and send it to a repo, in this case I will be submitting it to my GCP project's [Container Registry](https://cloud.google.com/container-registry/docs/overview).

For ease I use this little script to automate the process, as it is somewhat cumbersome.

**build_and_upload.sh**
```
#!/bin/bash                                           
                                                                                                                          
PROJECT=$1                   
                   
gcloud auth configure-docker
                              
#build and upload nginx image to GCR
docker build -t itsame -f Dockerfile_itsame .
docker tag itsame gcr.io/$PROJECT/itsame
docker push gcr.io/$PROJECT/itsame
```

You would go `./build_and_upload.sh <myGCPprojectID>` and it does all the work for you.

**Pay special attention to the name of your Dockerfile: it
 should be Dockerfile_itsame.**

After following the previous steps, the image should be already in your project's Container Registry and ready to be used.

<br/>

## 5. Setup OAuth Consent screen with domain


In your GCP project's Console (Web UI) you would go to the left hamburguer menu, and select "APIs & Services > OAuth consent screen", and click your way into setting up and creating the OAuth constent screen. This is the initial page that will appear to visitors of your app, which will request them to log in to their Google account so it can check if the account is inside the project *and* has permission to access to app.

The **most important part here is to add in the "Authorized domains" your domain as an entry**.   

The entry should look like "example.com".

Fill in all other details as you optionally please.

<br/>

## 6. Create OAuth credentials and redirect page


Similarly to the previous steps, go to the Console, and click your way to "APIs & Services > Credentials". Create an "OAuth client ID" credential, with its Application type being "Web application". 

**Important: In the "Authorized redirect URIs" part you must add your domain (like https://example.com)**

Click save and create it. Once you save, you will be provided with the Client ID and the Client Secret. 

With the ClientID it will provide, we will add another "Authorized redirect URI". Edit the credentials and add the following URI:


`https://iap.googleapis.com/v1/oauth/clientIds/<clientID>:handleRedirect`

Replace clientID with the one in your newly created credentials. You should have this URI now and your domain. Save and let's keep going.

## 7. Create cluster

Now it's time to use the GKE magic and create a cluster with one single command:

`gcloud container clusters create test-cluster`

Thanks, based GCP.

In order to use it we will connect our kubectl client to the cluster using the CloudSDK.  
(**Note**: If you don't have kubectl installed you can install it with `gcloud components install kubectl`)

`gcloud container clusters get-credentials test-cluster`

This leaves kubectl ready to interact with the newly created cluster.
 

## 8. Create a namespace for the environment

Now I recommend to just read the following steps till the end so you understand how it is done, and then just use the **deploy-iap.yaml** file which compiles all of the snippets I am about to show. Remember to replace all necessary lines, as instructed in the file itself.

We will be creating a namespace for this test, as it is a good way to keep our objects organized inside the cluster. A namespace simply segregates groups of objects so that there aren't name conflicts between different applications within the same cluster.

Our namespace:

**namespace.yaml**
```
---                                                   
apiVersion: v1                                                                                                            
kind: Namespace
metadata:
  name: iap-party
```

If you put this into a file and wanted to submit it by itself you would just go:

`kubectl apply -f namespace.yaml`

<br/>

## 9. Create secrets for HTTPS certificates and OAuth token


Remember the certificate you generated in step 2? Well, it's time to use it.

There are two ways of proceeding for this part, either you hardcode the token and certificates into the YAML file which is not very smart security wise but very comfy to do (one-keystroke-deployment), or just input the files into the cluster using `kubectl` which manages all the base64 converting and processing, avoiding the part where you store your private keys in plain text (in base64). I am going to first explain how to do it the long and not so secure way.

### Option 1: The config file way

Do a `sudo su` and go fetch the files `privkey.pem` and `cert.pem` in the `/etc/letsencrypt/live/<domain-name>/` folder and copy them into your current working directory. Still with root, turn the contents of the files into base64 with the below commands:

```
# convert the certificate and key files into base64
base64 -w 0 cert.pem
base64 -w 0 privkey.pem
```

Copy and paste the output into this file (or part of the file deploy-iap.yaml):

**https-certs.yaml**
```
---
apiVersion: v1
kind: Secret
metadata:
  name: https-certs
  namespace: iap-party
type: kubernetes.io/tls
data:
  # the data is abbreviated in this example
  tls.crt: |
    <cert.pem in base64>  ############## REPLACE ###############
  tls.key: |
    <privkey.pem in base64>  ############## REPLACE ###############
# or also
# kubectl create secret tls https-certs --cert=./cert.pem --key=./privkey.pem -n iap-party
```
 
The code above is how a Secret object of type TLS would look. You need to fill in with the missing info though.

Now we need to do the same with the OAuth token we created in step 6. So go to "APIs & Services > Credentials", copy the client_id and client_secret into their own separate files (if you input the clientid and clientsecret in the command, <span style="color:red">**the credentials will be stored in the bash history**</span>, which is a basic security no-no!) and feed them to the base64 command:

```
base64 -w 0 clientid.txt
base64 -w 0 clientsecret.txt
```

Copy and paste the outputs to the yaml:

**oauth-token.yaml**
```
---
apiVersion: v1
kind: Secret
metadata:
  name: oauth-sec
  namespace: iap-party
type: Opaque
data:
  client_id: <clientID-in-base64>  ############## REPLACE ###############
  client_secret: <client_secret_base64>  ############## REPLACE ###############
# instead of this config above one can also run instead something like 
# kubectl create secret generic oauth-sec --from-file=client_id=./clientID.txt --from-file=client_secret=./clientsecret.txt -n iap-party
```


And now, you would be able to apply these files with a `kubectl apply -f` but I recommend changing it in **deploy-iap.yaml** and deploy this file in the end.

<span style="color:red">**Remeber to delete the cert.pem, privkey.pem, cliendID.txt and clientsecret.txt files!!  
Also careful with uploading the YAML file to any public git server..**</span>


### Option 2: The kubectl way

As in option 1, you would still go get the `cert.pem` and `privkey.pem` files to the letsencrypt folder, then `chown <youruser> <nameoffile>` them and finally run the following command:

```
kubectl create secret tls https-certs --cert=./cert.pem --key=./privkey.pem -n iap-party
```

Then do the same with the clientID.txt and clientsecret.txt and run:
```
kubectl create secret generic oauth-sec --from-file=client_id=./clientID.txt --from-file=client_secret=./clientsecret.txt -n iap-party
```

If you follow option 2, you still have to remember to delete files and modify the file **deploy-iap.yaml** accordingly so it does not include the secrets you already created.

<br/>

## 10. Create a Deployment to serve the app

We will create a Deployment, that will make sure Pods are created to manage the containers with our app. In this deployment we define that we want at all times 3 pods running with our containers, using the image we uploaded to the GCR. I also added some resources limitations and I specified that the port opened in the container is the 8080.

The GCR image link you will have to add to this file should be something like:

`gcr.io/<projectID>/itsame:latest`

Otherwise you can go in the GCP Console to "Container Registry>Images" to check it.

**deployapp.yaml**
```
---                                                                                                                                                                                                 
apiVersion: apps/v1                                                                                                                                                                                 
kind: Deployment                                                                                                                                                                                    
metadata:                                                                                                                                                                                           
  name: hello-iap                                                                                                                                                                                   
  labels:                                                                                                                                                                                           
    app: hello-iap                                                                                                                                                                                  
  namespace: iap-party                                                                                                                                                                              
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-iap
  template:
    metadata:
      labels:
        app: hello-iap
    spec:
      containers:
        - name: helloitsme
          image: <link to Docker-image>   ############## REPLACE ###############
          ports: 
            - name: listenmain
              containerPort: 8080
              hostPort: 80
          resources:
            limits:
              cpu: 0.2
              memory: "10Mi"
```
<br/>

## 11. Create Backend config with the OAuth secret


We will need a Backend service for the load balancer, which is created with a Backend config. In the Backend config notice we state that IAP will be enabled and that it will be using the OAuth credentials we added in the secret, sections above.


**backend-config.yaml**
```
---
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: iap-back-config
  namespace: iap-party
spec:
  iap:
    enabled: true
    oauthclientCredentials:
      secretName: oauth-sec
```
<br/>

## 12. Create a Service referencing the Backend config

Then we create a service that will be using the Backend config. Notice that in here the function of the service is to map the port 8080 from the pod to the port 80 of all nodes within the cluster. This is accomplished by using the [type NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport).

**service.yaml**
```
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    beta.cloud.google.com/backend-config: '{"default": "iap-back-config"}'
  labels:
    app: hello-iap
  name: iap-service
  namespace: iap-party
spec:
  selector:
    app: hello-iap
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: NodePort

```



## 13. Create Ingress referencing the Service and the HTTPS certificate secret

Finally the Ingress object, which is the load balancer. The Ingress will be using TLS so we can have HTTPS, and must reference the service we defined previously. Take a look at the annotations, which contain the static IP address we created in the beginning.

**ingress.yaml**
```
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: iap-ingress
  annotations:
    kubernetes.io/ingress.global-static-ip-name: iap-gke
  labels:
    app: hello-iap
spec:
  tls:
  - secretName: https-certs
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: iap-service
          servicePort: 80
```

Now that we reviewed the whole configuration, go to the **deploy-iap.yaml**, fill in the gaps and deploy it with `kubectl apply -f deploy-iap.yaml`.

After deploying it all, you should wait for a bit (maybe 10 minutes) so that the Ingress turns on successfully and everything has stabilized. Go grab a coffee or something, you earned it.

<br/>

## 14. Give yourself permission to access through IAP

Once you visit the URL of your domain in the browser (https://example.com or something), you will be welcomed by a Google login page. This is IAP working properly. 

You don't have access yet.  

You can either go to the GCP Console in "Security->Identity-Aware Proxy" section, locate the iap-party/iap-service resource, click it and add yourself as a member with role "IAP-secured Web App User" in the expandable menu that will appear, or you can run the command below:

```
gcloud iap web add-iam-policy-binding --member='user:<yourGmailAddress>' --role='roles/iap.httpsResourceAccessor'
```

## 15. Troubleshooting

Above all, I recommend patience with IAP and an Ingress, as these resources take their time to apply changes. 

### Error 11

If you get this error after authenticating with IAP, try disabling and enabling IAP and wait 5 more minutes. It might even take a bit more, time is key in fixing this. Sometimes IAP takes some time to configure itself. Go have lunch instead of a coffee. For real.

### Red exclamation mark icon and access denied

Make sure you followed step 14 and waited some time, also **opening the URL in incognito mode helps** since it uses a clear cache and you might have stored the error page, which isn't updated upon visiting the URL.



