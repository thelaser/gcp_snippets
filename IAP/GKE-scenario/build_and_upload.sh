#!/bin/bash

PROJECT=$1

gcloud auth configure-docker

#build and upload nginx image to GCR
docker build -t itsame -f Dockerfile_itsame .
docker tag itsame gcr.io/$PROJECT/itsame
docker push gcr.io/$PROJECT/itsame
