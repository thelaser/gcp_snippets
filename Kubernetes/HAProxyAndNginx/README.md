# About

In this sample, two containers are created. One with **HAProxy** and another with **nginx**.  
The HAProxy container listens on the port 8080 and is mapped to the port 80 of the host, the requests coming to the HAProxy go to the nginx container on port 5000.  
The nginx container serves the output of cowsay.  

The sample is done with composer and kubernetes, both versions do the same.

### To use the composer version

Simply cd into the composer_version folder and (assuming docker and docker-composer are installed and in the path) run:  
`docker-compose up`

You can check in another tab or shell that it is actually running by __*curling*__ your localhost.  

### To use the kubernetes version

In this version, we create a Pod object which has two containers inside, using the modified versions of the images we created previously, and a Service object, which is in charge of doing the mapping.  

You will need to have installed kubectl:  

`sudo apt-get install kubectl`

The images will have to be built and uploaded to GCR or the Docker Hub. I did it with the GCR following [this](https://cloud.google.com/container-registry/docs/pushing-and-pulling).  
For debugging purposes, I created a little script that automates the building and uploading of the images. The usage is like this:  
`./build_and_upload.sh <GCP_project_ID>`

After the images are uploaded you have to edit both pod_service.yaml and pods.yaml files, adding your project ID in the <projectID> replacement keywords.  

Finally one should first [connect to the cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl), and then run these commands:  
`kubectl apply -f pods.yaml`
`kubectl apply -f pod_service.yaml`

By doing this you will have deployed the samples, to see the IP of the LoadBalancer with your Endpoint you can run:  
`kubectl get services`

Open up the IP in a browser and happy mooin!1  
