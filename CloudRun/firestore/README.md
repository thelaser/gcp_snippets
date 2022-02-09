# Interacting with a Firestore database from a Cloud Run app

## Intro

There are different ways to interact with Firestore, one of them is to use the Firebase SDK, which would mean that the Firestore database is hosted in Firebase and specifically in a Firebase project. This is the case for [this guide](https://cloud.google.com/community/tutorials/building-flask-api-with-cloud-firestore-and-deploying-to-cloud-run) from which I take inspiration. But in my case I will be using a Firestore database in GCP, which also integrates this kind of database, and for that I will be using the Python Cloud libraries for Firestore. Therefore the code in the guide I referenced a few lines above needs some modifications, which were applied in order for the GCP libraries to work.

## Steps followed to create the scenario

Before running any of the following commands, make sure you have configured the gcloud CLI to the project where you want to deploy this example:
```
gcloud config set project <yourProjectID>
```

### Create an SA for the scenario and download JSON key for local testing
```
export PROJECT_ID=<yourProjectID>
gcloud iam service-accounts create sample-firestore --display-name="Example firestore SA"
gcloud iam service-accounts list
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:"sample-firestore@$PROJECT_ID.iam.gserviceaccount.com" --role=roles/datastore.user
gcloud iam service-accounts keys create firekeys.json --iam-account="sample-firestore@$PROJECT_ID.iam.gserviceaccount.com"
```

### Get all the files ready for testing

The files needed will be the **main.py** to run the Flask code to do the requests, the **Dockerfile** preparing the container which will run our Python app in Cloud Run together with the **requirements.txt** file to install modules for Python.  

I changed the code in the guide referenced above, so that app.py will use the [Cloud Libraries for Firestore](https://googleapis.dev/python/firestore/latest/index.html) instead of the Firebase SDK. Also, for local debugging(running the Flask app in a container locally using Docker), I used the [Auth libraries](https://googleapis.dev/python/google-auth/latest/user-guide.html#obtaining-credentials) to load a service account JSON key file.

Debug commands:
```
docker build -t firebasetest . && docker run -p 80:80 firebasetest
curl localhost/add -H 'Content-Type: application/json' -d '{"hello":"my_hello","bye":"my_bye", "id":"works"}'
curl localhost/list 
```

Once I made sure the /add and /list functions worked in my local testing environment, by running the above curl commands and seeing changes reflected both in the /list and by looking the Firestore section in my GCP project, I moved to the next part: making this work with Cloud Run.

### Preparing to deploy to Cloud Run

Make sure you delete the service account JSON key from your system before proceeding (you won't need them anymore, and even with a .gitignore to avoid pushing them or a .dockerignore it is not necessary for you to keep the file, for security reasons)

I also set up fixed versions for the Python modules in the requirements.txt

It must also be noted that I changed the Dockerfile in the guide so that it will be using the gunicorn WSGI, otherwise it cannot run in Cloud Run.

To deploy it to Cloud Run, the following changes were done to the local debugging file:

main.py: 
- commented lines 12-16 and uncommented lines 18-20. Locally we use a JSON key file for the service account, in Cloud Run the service account is specified when running the deploy command
Dockerfile:
```
(debug line) CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
(deploy line) CMD exec gunicorn --bind :80 --workers 1 --threads 8 --timeout 0 main:app
```

One last thing, the service account we created previously needs [specific permissions](https://cloud.google.com/run/docs/deploying#permissions_required_to_deploy) in order to deploy to Cloud Run, so we need to grant these permissions:

```
export PROJECT_ID=<yourPprojectID>
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:sample-firestore@$PROJECT_ID.iam.gserviceaccount.com" --role=roles/run.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:sample-firestore@$PROJECT_ID.iam.gserviceaccount.com" --role=roles/iam.serviceAccountUser

```

### Deploying

`gcloud run deploy --allow-unauthenticated --source . --region europe-west1 --service-account <previouslyCreatedSAAddress> firetest`

NOTE: If it's the first you use Cloud Run and activate all the APIs, including **Cloud Build** most likely it will fail with something similar to this:

ERROR: (gcloud.run.deploy) INVALID_ARGUMENT: could not resolve source: googleapi: Error 403: **<projectNumber>**@cloudbuild.gserviceaccount.com does not have storage.objects.get access to the Google Cloud Storage object., forbidden

The cause for this is that the Cloud Build service account has not yet been created because the API was just enabled. The solution is to wait a few minutes for the SA to be created..

### Test the results

Go to the generated Cloud Run URL and open it in the path /list to see the previously created entries when testing. Or add new ones using curl and list them.

```
#to list
curl https://firetest-ocdmv4wuvq-ew.a.run.app/list

#to add new values
curl https://firetest-ocdmv4wuvq-ew.a.run.app/add -H 'Content-Type: application/json' -d '{"id":"runtest","howdiditgo?":"well!!"}'
```
