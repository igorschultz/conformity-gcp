#!/bin/bash
set -e

while getopts d:o:c: args
do
  case "${args}" in
    d) DEPLOYMENT_NAME=${OPTARG};;
    o) CLOUD_ONE_API_KEY=${OPTARG};;
    c) CLOUD_ONE_REGION=${OPTARG};;
  esac
done

GCP_PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2> /dev/null)
ORG_ID=$(gcloud organizations list --format 'value(ID)')
PROJECT_LIST_ID=$(gcloud projects list --format="value(PROJECT_ID)")

for project in $PROJECT_LIST_ID
do
# Enable Google APIs
echo "Enabling Google Cloud APIs for projects..."
gcloud services enable dns.googleapis.com bigquery.googleapis.com bigquerymigration.googleapis.com bigquerystorage.googleapis.com cloudapis.googleapis.com cloudresourcemanager.googleapis.com iam.googleapis.com accessapproval.googleapis.com cloudkms.googleapis.com compute.googleapis.com storage.googleapis.com sqladmin.googleapis.com dataproc.googleapis.com container.googleapis.com logging.googleapis.com pubsub.googleapis.com cloudresourcemanager.googleapis.com
echo "Conformity required APIs are enabled"
done

# Create a custom role containing the permissions below:
echo "Deploying Cloud One Conformity Role..."
CONFORMITY_ROLE=$(gcloud iam roles create CloudOneConformityAccess --organization=$ORG_ID --file=../cc-roles.yaml)
echo "Conformity custom role created"
echo $CONFORMITY_ROLE

# Create Cloud One Conformity Service Account
echo "Deploying Cloud One Conformity Service Account..."
CONFORMITY_SA_EMAIL=$(gcloud iam service-accounts create cloud-one-conformity-bot --description="GCP service account for connecting Cloud One Conformity Bot to GCP" --display-name="Cloud One Conformity Bot")
echo "Conformity Service Account created"
echo $CONFORMITY_SA_EMAIL

# Create Cloud One Conformity Service Account
echo "Binding Conformity role to Service Account..."
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID --member=serviceAccount:$CONFORMITY_SA_EMAIL --role=$CONFORMITY_ROLE

# Generate a Service Account JSON key
echo "Generating JSON file..."
gcloud iam service-accounts keys create Conformitykey.json --iam-account=cloud-one-conformity-bot@$GCP_PROJECT_ID.iam.gserviceaccount.com

echo "------------------------"
echo "Adding GCP Project to Cloud One Console..."
echo "------------------------"

CONFORMITY_SA_UID=$(gcloud iam service-accounts describe $CONFORMITY_SA_EMAIL --format 'value(uniqueId)')
PROJECT_LIST_NAME=$(gcloud projects list --format='value(NAME)')
PROJECT_LIST_ID=$(gcloud projects list --format="value(PROJECT_ID)")

for project in $PROJECT_LIST_ID
do
gcloud projects add-iam-policy-binding $project --member=serviceAccount:$CONFORMITY_SA_EMAIL --role=roles/compute.viewer
PROJECT_NAME=$(gcloud projects list --filter=$project --format='value(NAME)')
ADD_ACCOUNT=$(wget -qO- --no-check-certificate \
  --method POST \
  --timeout=0 \
  --header 'Api-Version: v1' \
  --header 'Content-Type: application/vnd.api+json' \
  --header "Authorization: ApiKey $CLOUD_ONE_API_KEY" \
  --body-data '{
  "data": {
    "type": 'account',
    "attributes": {
      "name": '\"$DEPLOYMENT_NAME\"',
      "access": {
        "projectId": '\"$project\"',
        "projectName": '\"$PROJECT_NAME\"',
        "serviceAccountUniqueId": '\"$CONFORMITY_SA_UID\"' 
      } 
    }    
  }	
}' \
"https://conformity.$CLOUD_ONE_REGION.cloudone.trendmicro.com/api/accounts/gcp" | jq '.stackID' | tr -d '"') 
done

echo "The project has been added successfully to Cloud One Conformity. Go to your Cloud One Conformity console to check this out."
