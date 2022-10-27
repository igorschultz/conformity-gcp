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
1. Copy and execute the script below in the Cloud Shell to complete the project setup.

<walkthrough-project-setup></walkthrough-project-setup>

```sh
gcloud config set project <walkthrough-project-id/>
```

--------------------------------

## Set Cloud One Conformity Custom Role to Service Account

You need to identify the Cloud Conformity Bot Service Account ID that has been created earlier and set as member for this project and with the appopriate policy.

```sh
gcloud iam service-accounts add-iam-policy-binding <walkthrough-project-id/> \
    --member=serviceAccount:cloud-one-conformity-bot@<PROJECT_ID>.iam.gserviceaccount.com
    --role=projects/<walkthrough-project-id/>/roles/CloudOneConformityAccess
```

--------------------------------
