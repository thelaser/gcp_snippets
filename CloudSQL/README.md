# A scenario with Cloud SQL

## Creating the Cloud SQL instance

Go to GCP's Cloud Console and [create](https://cloud.google.com/sql/docs/mysql/create-instance#create-2nd-gen) a Cloud SQL instance [connected](https://cloud.google.com/sql/docs/mysql/configure-private-ip#gcloud) to a subnet with [Private access](https://cloud.google.com/vpc/docs/configure-private-google-access#enabling-pga) to Google's services. Meaning it will have access to other resources in your network, since Cloud SQL instances are created inside special managed projects by Google and not in your own project.

Add private access to a subnet in the default network:
```
   gcloud compute networks subnets update SUBNET_NAME \
   --region=REGION \
   --enable-private-ip-google-access
```
Create the Cloud SQL instance (it may ask to enable sqladmin.googleapis.com):
``` 
   gcloud beta sql instances create myinstance \
   --database-version=MYSQL_8_0 \
   --cpu=4 \
   --memory=7680MB \
   --region=REGION \
   --network NETWORK \
   --no-assign-ip \
   --root-password=ROOT_PASSWORD
```
Always remember(!!!): When running a command in the shell using a password, add a space before the command so it doesn't get saved to the bash history (or whatever shell you use)  

## Access from a [bastion](https://cloud.google.com/solutions/connecting-securely#bastion) instance

`mysql -u root -p PASSWORD -h INTERNAL_IP`  

Verify if it works..  

## Get a dataset and upload it into the instance

For this sample I will be using [this Youtube dataset](https://www.kaggle.com/datasnaek/youtube-new/) from Kaggle. An account is needed to download it.  

After downloading it from Kaggle, upload it to an instance or a Storage bucket. I [used](https://cloud.google.com/storage/docs/uploading-objects#uploading-an-object) a bucket. It is also possible to upload directly to an instance, [there are many ways](https://cloud.google.com/compute/docs/instances/transfer-files).  

### Option 1: with gcloud

Create new db:
```
mysql -u root -pPASSWORD -h 172.30.210.4 -e "create database videosdb; show databases;"
```

Install tools to create SQL table schema file:
```
sudo apt-get install python-dev python3-pip python-setuptools build-essential
pip3 install --upgrade setuptools
pip3 install --upgrade csvkit
```
If after this csvsql is not added to path search the binaries and add them to the path:
(sudo find -name csvsql) and add to path the binaries:

`export PATH=PATH:/home/USER/.local/bin/`

Then create a table schema file from the CSV:  

```
#directly upload the schema to the db 
csvsql --db mysql://user:password@localhost:3306/dbschema --tables mytable --insert file.csv
#OR create the file and then upload it to the db, creating the table
csvsql --dialect mysql -z 10000000000 USvideos.csv > USvideos.sql
mysql -u root -p -h IPADDRESS DATABASENAME < USvideos.sql -vvvv
```
Check it was created:

`mysql -u root -pPASSWORD -h IPADDRESS -e "use videosdb; show tables;"`

Let's use [gcloud sql import csv](https://cloud.google.com/sdk/gcloud/reference/sql/import/csv) to [import the CSV file](https://cloud.google.com/sql/docs/mysql/import-export/import-export-csv#import_data_from_a_csv_file) into the database.  

Import the data into the table with gcloud:
```
gcloud sql instances describe myinstance | grep service
gcloud projects add-iam-policy-binding PROJECT-ID --member=serviceAccount:SAADRESS --role=roles/storage.objectViewer
gcloud sql import csv myinstance gs://obrasdearte/USvideos.csv --database=videosdb --table=USvideos
```

### Option 2: without gcloud
Create new db:
```
mysql -u root -pPASSWORD -h 172.30.210.4 -e "create database videosdb; show databases;"
```

Install tools to create SQL table schema file:
```
sudo apt-get install python-dev python3-pip python-setuptools build-essential
pip3 install --upgrade setuptools
pip3 install --upgrade csvkit
```
If after this csvsql is not added to path search the binaries and add them to the path:
(sudo find -name csvsql) and add to path the binaries:

`export PATH=$PATH:/home/USER/.local/bin/`

Then create a table schema file from the CSV:  

```
#directly upload the schema to the db 
csvsql --db mysql://user:password@localhost:3306/dbschema --tables mytable --insert file.csv
#OR create the file and then upload it to the db, creating the table
csvsql --dialect mysql -z 10000000000 USvideos.csv > USvideos.sql
mysql -u root -p -h IPADDRESS DATABASENAME < USvideos.sql -vvvv
```
Check it was created:

`mysql -u root -pPASSWORD -h IPADDRESS -e "use videosdb; show tables;"`

Import it:

`mysqlimport --ignore-lines=1 --fields-terminated-by=, --local --host=IPADDRESS -u root -p USvideos USvideos.csv`

## Do some queries 

Once the dataset is imported into MySQL, let's find the 15 most liked videos

```
show columns from USvideos;
select title, MAX(likes) as 'likes' from USvideos group by title ORDER BY `likes` DESC limit 15;
```
