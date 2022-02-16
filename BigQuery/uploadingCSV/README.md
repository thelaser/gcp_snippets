# Uploading CSV

Download the dataset:
https://www.kaggle.com/gabrielramos87/bike-trips?select=New+York+Citibike+Trips.csv

Upload to bucket 
`gsutil cp <csvfile> gs://..`

Set the right project:
`gcloud config set project $PROJECT_ID`

Set right permissions:  
`gcloud projects add-iam-policy-binding $PROJECT --member="user:$USER_ACC" --role="roles/bigquery.admin"`  
`gcloud projects add-iam-policy-binding $PROJECT --member="user:$USER_ACC" --role="roles/storage.admin"`  

Create a dataset and a table, then load the file.
```
bq mk -d --location=europe-west1 biketrips

bq mk -t --location=europe-west1 biketrips.newyork

bq load \                                                                           paugarcia@sigh
--location=europe-west1 \
--source_format=CSV \
--autodetect \
biketrips.newyork \
"gs://<bucket_name>/New York Citibike Trips.csv"

bq ls biketrips
# check which fields we can use to make queries
bq head --max_rows=10 biketrips.newyork
```

Do some queries, for example show longest trip time related with age:
```
bq query \
--use_legacy_sql=false \
'SELECT
  age,
  trip_duration
FROM
 '$PROJECT.biketrips.newyork'
ORDER BY trip_duration DESC'
```

# Reference
https://www.kaggle.com/gabrielramos87/bike-trips?select=New+York+Citibike+Trips.csv
https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv#bq
https://cloud.google.com/bigquery/docs/reference/bq-cli-reference#bq_load
