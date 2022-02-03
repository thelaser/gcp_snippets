## Simple Cloud Run and Tasks demo

Create the Cloud Tasks queue:  
`gcloud tasks queues create <queuename> --region europe-west1`  
Deploy the Cloud Function:  
`gcloud functions deploy --region europe-west1 --runtime=go116 --trigger-http --allow-unauthenticated --entry-point HelloWorld --source function/ <functionname>`  
Deploy the app in Cloud Run:  
`gcloud run deploy --allow-unauthenticated --source . --region europe-west1 --service-account <SA address> <deploymentname>`  


The Service account used by Cloud Run must have Cloud Tasks Admin role (or enough perms to create tasks)

References:  
https://cloud.google.com/run/docs/quickstarts/build-and-deploy/python  
https://cloud.google.com/tasks/docs/creating-http-target-tasks  
https://cloud.google.com/run/docs/triggering/using-tasks#python  
https://cloud.google.com/sdk/gcloud/reference/functions/deploy
https://cloud.google.com/sdk/gcloud/reference/run/deploy
