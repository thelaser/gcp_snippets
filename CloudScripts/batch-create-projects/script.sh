
# ----------------  TODO ---------
# - Formatting checkups need to be added (orgid_user and foldername must be valid, billing account format is 0X0X0X-0X0X0X-0X0X0X with A-Z0-9 chars)
# - The accounts must be created beforehand inside the destination organization
# - Add USAGE
# - Fail behavior
# - Explain requirements: Cloud SDK installed and Beta component installed too.

# SETTING ARGUMENTS ################


# $1 = folder name
foldername=$1
# $orgid_user = organization ID to where the users belong
orgid_user=$2
#orgid_folder = organization ID where the projects and folder will be created
orgid_folder=$3
# $baccount = billing account
baccount=$4
# $tfolderid = [target folder ID] (optional arg)
tfolderid=$5
# $namesfile = names-file path
namesfile='name-list'
if [ -z "$6" ]
then
  namesfile=$6
fi

####################################


# get the Organization for display
orgname_fold=$(gcloud organizations describe $orgid_folder | grep display | awk '{print $2}')
orgname_user=$(gcloud organizations describe $orgid_user | grep display | awk '{print $2}')

echo "\nWe will now create the folder $foldername inside organization $orgname_folder/$orgid_folder \n"
echo "A project will be created for each of the users in the file $namesfile: \n"
echo "$(cat $namesfile) \n\n"

# if $tfolderid is empty, create a folder in the root of an organization, otherwise create it inside the folder provided
folderid="empty"
if [ -z "$tfolderid" ]
then
    gcloud resource-manager folders create --display-name=$foldername --organization=$orgid_folder
    folderid=$(gcloud resource-manager folders list --organization $orgid_folder | grep $foldername | awk '{print $3}')
else
    gcloud resource-manager folders create --display-name=$foldername --folder=$tfolderid
    folderid=$(gcloud resource-manager folders list --folder $tfolderid | grep $foldername | awk '{print $3}')
fi

echo "\nThe ID for the new folder is $folderid \n"

# we will set all accounts to have Owner permissions inside the folder where the projects will be located
for i in $(cat $namesfile); do
    echo "\n-------------------------------------------------- \n\n"
    user="$i@$orgname_user"
    gcloud resource-manager folders add-iam-policy-binding $folderid --member="user:$user" --role='roles/owner'
    echo "\n\nSet Owner permission for $user in folder $foldername/$folderid \n\n"
done

#create the projects for each user, which will inherit the permissions
for i in $(cat $namesfile); do
    echo "\n-------------------------------------------------- \n\n"
    gcloud projects create --folder=$folderid $foldername-$i
    gcloud beta billing projects link $foldername-$i --billing-account=$baccount
    echo "\nProject for user $i was created and linked to billing account $baccount\n\n"
done

echo "\nWe are done here!\n"
