# About

In this sample, two containers are created. One with **HAProxy** and another with **nginx**.  
The HAProxy container listens on the port 8080 and is mapped to the port 80 of the host, the requests coming to the HAProxy go to the nginx container on port 5000.  
The nginx container serves the output of cowsay.  

The sample is done with composer and kubernetes, both versions do the same.

### To use the composer version

Simply cd into the composer_version folder and (assuming docker and docker-composer are installed and in the path) run:
`docker-compose up`

### To use the kubernetes version

[On the works]
