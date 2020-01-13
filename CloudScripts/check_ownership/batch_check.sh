#!/bin/bash

####################################################################
######################### ARGUMENT PARSING #########################
####################################################################

# default values
WORKDIR="."
FILE_NAME="name-list"


if [[ "$*" == *-h*  ]] || [[ "$*" == *--help*  ]]
then

	echo -e "./batch_check.sh [-f=<file_name>] [-d=<workdir>]\n"
	echo -e "\n <file_name> = only the name of the input file\n"
	echo -e "\n <workdir> = workdir where the input and output files are located\n"
	exit 1

else
    
	for i in "$@"
	do
	case $i in
			-f=*|--input-file=*)
			FILE_NAME="${i#*=}"
			;;
			-d=*|--workdir=*)
			WORKDIR="${i#*=}"
			;;
			*)
							# unknown option
			;;
	esac
	done
fi


echo "$FILE_NAME"
echo "$WORKDIR"

####################################################################
############################## MAIN ################################
####################################################################

FILE_PATH="$WORKDIR/$FILE_NAME"
USERS_TO_CHECK=$(cat $FILE_PATH)
SCRIPT_PATH=$(dirname "$0")

echo -e "Will check the following accounts: \n\n$USERS_TO_CHECK\n\n"

for USER in $USERS_TO_CHECK;
do 
	echo -e "Checking $USER \n"
	$SCRIPT_PATH/check_projects_ownership.sh $USER > $WORKDIR/$USER-permissions
done
