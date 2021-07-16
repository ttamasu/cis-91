#! /bin/bash 

if [ -z "$1" ]; then 
    echo "usage: $0 <keyfile>"
    exit 1 
fi 

KEYFILE="$1"

if [ -f "$KEYFILE" ]; then 
    echo "ERROR: Key file \"$KEYFILE\" already exists."
    exit 1 
fi 

if [ ! -d $(dirname "$KEYFILE") ]; then 
    echo "ERROR: Can't create a key file in a non-existant directory:" $(dirname "$KEYFILE")
    exit 1
fi

PROJECT_ID=$(gcloud config get-value core/project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then 
    echo "No project set"
    exit -1
fi 

gcloud iam service-accounts create sa-infra-user \
    --description="Service account to be used by terraform and ansible." \
    --display-name="sa-infra-user"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:sa-infra-user@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/owner"

gcloud iam service-accounts keys create ${KEYFILE} \
    --iam-account="sa-infra-user@${PROJECT_ID}.iam.gserviceaccount.com"

