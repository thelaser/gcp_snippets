# About

This is taken from the official Kubernetes GitHub repository, I'm just collecting it in here for ease of access and recopilatory purposes.  

A guide on how to set it up can be found in [here](https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook).  

And the source code in [this folder](https://github.com/kubernetes/kubernetes/tree/release-1.10/examples/guestbook) in the Kubernetes repo.  

There are a few differences between the guide in the Google Cloud Documentation and the files in this repo: the Service and Depoyment objects for the frontend and redis have been joined in a single file for each.  

The images used for the Deployments are also added in their respective folders:

frontend -> ./php-redis/
slave-redis -> ./slave-redis/
master-redis -> uses the default image for redis in the docker hub

## What it does

What this setup does is to create 3 Deployments (frontend, slave-redis and master-redis) which create a ReplicaSet with some containers.  

The __frontend__ Deployment is mapped with a LoadBalancer type Service object to serve some replicas from the port 80 in the cluster Endpoint.  
The __master-redis__ Deployment is mapped internally with a ClusterIP type Service object to listen for __writes__ in the port 6379. When it receives those writes, it sends the changes to the slave-redis Pods.  
The __slave-redis__ Deployment is mapped internally with a ClusterIP type Service object to listen for __reads__ in the port 6379.  

## How to use it

In order to have this run in a Kubernetes cluster, one must first setup the cluster and connect the kubectl client to the master node.  

After that is done, it is a matter of applying these configs:  

`k apply -f frontend.yaml && k apply -f master-redis.yaml && k apply -f slave-redis.yaml`  
