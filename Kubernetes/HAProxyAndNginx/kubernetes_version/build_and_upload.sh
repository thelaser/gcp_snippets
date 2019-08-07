#!/bin/bash

PROJECT=$1

gcloud auth configure-docker

#build and upload haproxy image to GCR
docker build -t haproxy_container -f Dockerfile_haproxy .
docker tag haproxy_container gcr.io/$PROJECT/haproxy_container
docker push gcr.io/myplaygrounds-inter/haproxy_container

#build and upload nginx image to GCR
docker build -t nginx_container -f Dockerfile_nginx .
docker tag nginx_container gcr.io/$PROJECT/nginx_container
docker push gcr.io/myplaygrounds-inter/nginx_container


