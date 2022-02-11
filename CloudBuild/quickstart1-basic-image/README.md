# Setting up a Hello world container in Cloud Run using Cloud Build

Based off [this quickstart](https://cloud.google.com/build/docs/configuring-builds/create-basic-configuration) with some modifications

In this quickstart, it is shown how to upload a basic configuration to Cloud Build, deploying a Hello World container inside of a Compute Instance instance created by Cloud Build. I decided to create my own files, but you can just clone the git from the guide and use the files inside:

`git clone https://github.com/GoogleCloudPlatform/cloud-build-samples/tree/main/basic-config`

## Service accounts

Enable the Cloud Build and Artifact Repositories if you haven't, and make sure the Cloud Build SA is created.

You will need to give the Cloud Build service account the following permissions:  
- Cloud Run Admin (roles/run.admin, without this specific role, the --allow-unauthenticated flag cannot be applied)  
- Service Account User (roles/iam.serviceAccountUser, to impersonate other service accounts)
- Compute Instance Admin v1 (roles/compute.instanceAdmin.v1, to create the GCE instance)


```
export PROJECT_ID=<yourProjectID>
export PROJECT_NUMBER=<yourProjectNumber>
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" --role=roles/run.admin
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" --role=roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" --role=roles/compute.instanceAdmin.v1

```

## Submitting the build

Before submitting to Cloud Build you will need to **create a repo in Artifact Registry**, as it must be previosly created. We could configure Cloud Build to create a new repo, but this is not the case here. So make sure your repo already exists and that your reference to it points to the right location etc. I modified the code sample so that it points to the **europe-west1 region**, make sure you create the repo there or that you modify the code, otherwise it won't work.

Go to the folder where you have the files, and run (replacing with the IDs for what you just created):

`gcloud builds submit`
