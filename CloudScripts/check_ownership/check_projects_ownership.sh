################
# Explanations #
################

# This script finds and shows from the list of projects accessible by the active account, the projects owned explicitly by an account in GCP (without counting inheritances from an organization)
# If run without arguments, it will perform the search for the account being currently used with Cloud SDK
# Otherwise it can accept one argument which will be the account to check ownerships for.

# Example of usage:
# ./check_projects_ownership.sh myaccount@mydomain.com

#####################
# One-liner version #
#####################

# (for project in $(gcloud projects list --format 'value(project_id)'); do if [ $(gcloud projects get-iam-policy $project --format json 2>/dev/null|jq '.bindings[]|select(.role=="roles/owner").members'|grep -E "user:$(gcloud config get-value account)") ]; then echo $project; fi; done >> myprojects.txt)&

####################
# Expanded version #
####################

if [ $1 ]; then
	ACCOUNT=$1
else
	ACCOUNT=$(gcloud config get-value account)
fi

echo -e "Checking project ownerships for the account $ACCOUNT \n" 
	
PROJECT_LIST=$(gcloud projects list --format 'value(project_id)')

for PROJECT in $PROJECT_LIST; 
do 
	PROJECT_POLICIES=$(gcloud projects get-iam-policy $PROJECT --format json 2>/dev/null)
	OWNER=$(echo $PROJECT_POLICIES | jq '.bindings[]? | select(.role?=="roles/owner").members?' | grep "user:$ACCOUNT")
	if [ $OWNER ]; then
		echo $PROJECT; 
	fi 
done
