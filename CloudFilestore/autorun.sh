#https://cloud.google.com/run/docs/tutorials/network-filesystems-filestore
#https://stackoverflow.com/questions/55788714/deploying-to-cloud-run-with-a-custom-service-account-failed-with-iam-serviceacco
#https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration

INSTANCE_ID=mynfsinstance2
CONNECTOR_NAME=nfsconnector2
REGION=europe-west1
ZONE=europe-west1-b
FILE_SHARE_NAME=nfsmounter2
RUN_APP_NAME=filesystemapp2
REGION=europe-west1
NETWORK=default
PROJECT_ID=<projectID>

gcloud filestore instances create $INSTANCE_ID \
    --tier=STANDARD \
    --file-share=name=$FILE_SHARE_NAME,capacity=1TiB \
    --network=name=$NETWORK \
    --zone $ZONE;

gcloud compute networks vpc-access connectors create $CONNECTOR_NAME \
  --region $REGION \
  --range "10.25.0.0/28";

export FILESTORE_IP_ADDRESS=$(gcloud filestore instances describe $INSTANCE_ID --zone $ZONE --format "value(networks.ipAddresses[0])");

gcloud iam service-accounts create fs-identity &&

gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:fs-identity@$PROJECT_ID.iam.gserviceaccount.com" --role=roles/run.admin

gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:fs-identity@$PROJECT_ID.iam.gserviceaccount.com" --role=roles/iam.serviceAccountUser


gcloud beta run deploy $RUN_APP_NAME --source . \
    --vpc-connector $CONNECTOR_NAME \
    --execution-environment gen2 \
    --allow-unauthenticated \
    --service-account fs-identity \
    --update-env-vars FILESTORE_IP_ADDRESS=$FILESTORE_IP_ADDRESS,FILE_SHARE_NAME=$FILE_SHARE_NAME \
    --region $REGION
