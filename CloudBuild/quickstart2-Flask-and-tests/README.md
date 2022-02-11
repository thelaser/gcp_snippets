# Setting up Cloud Build to deploy a Cloud Run service with container running Flask 

These are tips on how to go through [this Quickstart](https://cloud.google.com/build/docs/building/build-python)

## Files needed

All files in [this repo](https://github.com/GoogleCloudPlatform/cloud-build-samples/tree/main/python-example-flask) referenced in the Quickstart. No edits on the files are needed.

Clone it into your working dir:

`git clone https://github.com/GoogleCloudPlatform/cloud-build-samples/tree/main/python-example-flask`

## Tips

### Service accounts

Enable the Cloud Build and Artifact Repositories if you haven't, and make sure the Cloud Build SA is created.

You will need to give the Cloud Build service account the following permissions:  
- Storage Object Creator (roles/storage.objectCreator, Cloud Build inserts files into a bucket, so we need permissions for that)
- Cloud Run Admin (roles/run.admin, without this specific role, the --allow-unauthenticated flag cannot be applied)  
- Service Account User (roles/iam.serviceAccountUser, to impersonate other service accounts)

```
export PROJECT_ID=<yourProjectID>
export PROJECT_NUMBER=<yourProjectNumber>
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" --role=roles/run.admin
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" --role=roles/storage.objectCreator
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" --role=roles/iam.serviceAccountUser
```

### Submitting the build

Before submitting to Cloud Build you will need to **create a repo in Artifact Registry**, as it must be previosly created. We could configure Cloud Build to create a new repo, but this is not the case here. So make sure your repo already exists and that your reference to it points to the right location etc. By default, the code sample points to the **us-central1 region**, make sure you create the repo there or that you modify the code, otherwise it won't work.

You will also need to **create a Cloud Storage bucket** where to store the resulting artifacts, which are non-container image files, such as logs and other common files.

Finally, go to the folder where you have the files, and run (replacing with the IDs for what you just created):

`gcloud builds submit --substitutions=_REPO_NAME=<yourrepo>,_BUCKET_NAME=<yourbucket>,SHORT_SHA=randomval`  

We will add the variables manually in this demo case with --substitutions, these vars will normally contain a value if the build is triggered by an event, but since we are doing this manually from a CLI, in order for the demo to work the values must be explicitly provided. SHORT_SHA can be random string in this case.
