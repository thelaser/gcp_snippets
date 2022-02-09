https://cloud.google.com/community/tutorials/building-flask-api-with-cloud-firestore-and-deploying-to-cloud-run

gcloud run deploy --allow-unauthenticated --source . --region europe-west1 --service-account <SA address> <deploymentname>

Debug:
docker build -t firebasetest .
docker run -p 8080 firebasetest

