#!/bin/bash

ORG_ID=$1
ROLE=$2
BILLING_PROJECT=$3

cat name-list | while read line; do $(gcloud organizations remove-iam-policy-binding $ORG_ID --condition=None --member="user:$line" --role=$ROLE --billing-project=$BILLING_PROJECT); done
