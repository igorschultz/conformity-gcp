# Cloud One Conformity

# Assign Access to the Service Account for Projects

## Overview

<walkthrough-tutorial-duration duration="10"></walkthrough-tutorial-duration>

This tutorial will guide you to add new GCP Projects to an existing Cloud One Conformity Service Account.

--------------------------------

### Permissions

Before you start to add the projects, you need to ensure the required permissions were created at the project level or organization level:

For more information about the required permissions, see [Custom role](https://cloudone.trendmicro.com/docs/conformity/add-a-gcp-account/#create-a-custom-role).

## Project setup

1. Select the project from the drop-down list.
2. Copy and execute the script below in the Cloud Shell to complete the project setup.

<walkthrough-project-setup></walkthrough-project-setup>

```sh
gcloud config set project <walkthrough-project-id/>
```


## Enable permissions for deployment

List the APIs that are enabled:

```sh
gcloud services list --enabled
```

Enable all the needed APIs at once:

```sh
gcloud services enable dns.googleapis.com bigquery.googleapis.com bigquerymigration.googleapis.com bigquerystorage.googleapis.com cloudapis.googleapis.com cloudresourcemanager.googleapis.com iam.googleapis.com accessapproval.googleapis.com cloudkms.googleapis.com compute.googleapis.com storage.googleapis.com sqladmin.googleapis.com dataproc.googleapis.com container.googleapis.com logging.googleapis.com pubsub.googleapis.com cloudresourcemanager.googleapis.com
```

## Map or create Cloud One Conformity custom role

To give the appropriate permissions to Conformity service account, you must ensure you have created the custom role at the organization level or the project level. 

To find Conformity custom role at the organization level, run:

```sh
gcloud iam roles list --organization=<ORGANIZATION_ID> --filter=CloudOneConformityAccess
```

If you need to create the role at the project level, run the following command:

```sh
gcloud iam roles create CloudOneConformityAccess --project=<walkthrough-project-id/> --file=./cc-roles.yaml
```

--------------------------------

## Set Cloud One Conformity Custom Role to Service Account

You need to identify the Cloud Conformity Bot Service Account ID that has been created earlier and set as member for this project and with the appropriate policy.

1. If you have created a project level custom policy, run:

```sh
gcloud iam service-accounts add-iam-policy-binding <walkthrough-project-id/> \
    --member=serviceAccount:<cloud-one-conformity-bot-Service-Account>
    --role=projects/<walkthrough-project-id/>/roles/CloudOneConformityAccess
```

Or

1. If you have created a organization level custom policy, run:

```sh
gcloud iam service-accounts add-iam-policy-binding <walkthrough-project-id/> \
    --member=serviceAccount:<cloud-one-conformity-bot-Service-Account>
    --role=organization/<ORGANIZATION_ID>/roles/CloudOneConformityAccess
```


--------------------------------
