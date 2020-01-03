# This script finds and shows the projects owned explicitly by an account in GCP (without counting inheritances from an organization)
# If run without arguments, it will find the accounts associated with the account being currently used with Cloud SDK
# It can accept one argument which will be the account to check ownerships for


if [ $1 ]; then
	ACCOUNT=$1
else
	ACCOUNT=$(gcloud config get-value account)
fi

echo "Checking project ownerships for the account $ACCOUNT \n" 
	
PROJECT_LIST=$(gcloud projects list --format 'value(project_id)')

for PROJECT in $PROJECT_LIST; 
do 
	PROJECT_POLICIES=$(gcloud projects get-iam-policy $PROJECT --format json 2>/dev/null)
	OWNER=$(echo $PROJECT_POLICIES | jq '.bindings[]? | select(.role?=="roles/owner").members?' | grep "user:$ACCOUNT")
	if [ $OWNER ]; then
		echo $PROJECT; 
	fi 
done
