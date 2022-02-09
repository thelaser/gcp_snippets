# [Quick quickstart](https://cloud.google.com/bigtable/docs/quickstart-cbt)

PROJECT_ID=<projectID>

gcloud iam service-accounts create bigtablesacc --display-name="big table service account"

gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:bigtablesacc@$PROJECT_ID.iam.gserviceaccount.com --role=roles/bigtable.admin

gcloud bigtable instances create quickstart-instance --display-name="Quickstart instance" --cluster-storage-type ssd --cluster-config=id=quickstart-instance-c1,zone=europe-west1-b

#install cbt
sudo apt-get install google-cloud-sdk-cbt

echo project = $PROJECT_ID > ~/.cbtrc
echo instance = quickstart-instance >> ~/.cbtrc

cbt createtable my-table
cbt ls
cbt createfamily my-table cf1
cbt ls my-table
cbt set my-table r1 cf1:c1=test-value
cbt read my-table
