# Prerequisites Setup Guide

This document provides step-by-step instructions to set up all the prerequisites for the RHEL Ansible Terraform Infrastructure CI/CD pipeline.

## Overview

This project uses:
- **Terraform** for infrastructure provisioning on Google Cloud Platform
- **Ansible** for configuration management
- **GitHub Actions** for CI/CD automation
- **Workload Identity Federation** for secure authentication

## Requirements

- Google Cloud Platform account with billing enabled
- `gcloud` CLI installed and authenticated
- GitHub repository access
- Basic knowledge of Terraform and Ansible

## Setup Instructions

### 1. Environment Variables Setup

First, set up your environment variables. Replace the placeholder values with your actual project details:

```bash
# Set your project variables
export PROJECT_ID="stellar-polymer-475409-a8"                    # Replace with your GCP project ID
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
export POOL_ID="github-actions-pool"
export PROVIDER_ID="github-actions-provider"
export SERVICE_ACCOUNT_NAME="github-actions-sa"
export GITHUB_REPO="misskecupbung/rhel-ansible-terraform-infra"
export ANSIBLE_BUCKET_NAME="$PROJECT_ID-ansible"  # Replace with unique bucket name
export TF_STATE_BUCKET="$PROJECT_ID-tfstate"
export REGION="us-central1"                            # Change to your preferred region
```

### 2. Set Active Project and Enable APIs

```bash
# Set the current project
gcloud config set project $PROJECT_ID

# Enable required Google Cloud APIs
gcloud services enable iamcredentials.googleapis.com
gcloud services enable sts.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable iam.googleapis.com
```

**Wait for APIs to be fully enabled (may take a few minutes)**

### 3. Create Service Account

```bash
# Create the service account for GitHub Actions
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="GitHub Actions Service Account" \
    --description="Service account for GitHub Actions CI/CD"

# Get the service account email
export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
```

### 4. Grant IAM Roles to Service Account

```bash
# Core roles for Terraform operations
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/resourcemanager.projectIamAdmin"

# Network and security roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.securityAdmin"
```

### 5. Create Workload Identity Pool

```bash
# Create the workload identity pool
gcloud iam workload-identity-pools create $POOL_ID \
    --project=$PROJECT_ID \
    --location="global" \
    --display-name="GitHub Actions Pool" \
    --description="Workload Identity Pool for GitHub Actions"
```

### 6. Create Workload Identity Provider

```bash
# Create the OIDC provider for GitHub Actions
gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID \
    --project=$PROJECT_ID \
    --location="global" \
    --workload-identity-pool=$POOL_ID \
    --display-name="GitHub Actions Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
    --attribute-condition="assertion.repository_owner == 'misskecupbung'" \
    --issuer-uri="https://token.actions.githubusercontent.com"
```

### 7. Configure Service Account Impersonation

```bash
# Allow GitHub Actions to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \
    --project=$PROJECT_ID \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/attribute.repository/$GITHUB_REPO"
```

### 8. Create Google Cloud Storage Bucket

```bash
# Create bucket for Ansible artifacts and Terraform state (if needed)
gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$ANSIBLE_BUCKET_NAME
gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$TF_STATE_BUCKET

# Set appropriate permissions
gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://$ANSIBLE_BUCKET_NAME
gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://$TF_STATE_BUCKET
```

### 9. Get GitHub Secrets Values

Run these commands to get the values you need to add as GitHub secrets:

```bash
# Display all required secret values
echo "=================================================="
echo "GitHub Repository Secrets Configuration"
echo "=================================================="
echo ""
echo "GCP_WORKLOAD_IDENTITY_PROVIDER:"
echo "projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"
echo ""
echo "GCP_SERVICE_ACCOUNT_EMAIL:"
echo "$SERVICE_ACCOUNT_EMAIL"
echo ""
echo "GCP_PROJECT_ID:"
echo "$PROJECT_ID"
echo ""
echo "ANSIBLE_BUCKET_NAME:"
echo "$ANSIBLE_BUCKET_NAME"

echo "TF_STATE_BUCKET:"
echo "$TF_STATE_BUCKET"
echo "=================================================="
```

### 10. Add Secrets to GitHub Repository

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each of the following secrets with the values from step 9:

| Secret Name | Description |
|-------------|-------------|
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Full resource name of the Workload Identity Provider |
| `GCP_SERVICE_ACCOUNT_EMAIL` | Email of the service account created above |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID |
| `ANSIBLE_BUCKET_NAME` | Name of the GCS bucket for Ansible artifacts |
| `TF_STATE_BUCKET` | Name of the GCS bucket for Terraform states |

## Verification Commands

### Verify Workload Identity Setup

```bash
# Check workload identity pool
gcloud iam workload-identity-pools describe $POOL_ID \
    --project=$PROJECT_ID \
    --location="global"

# Check workload identity provider
gcloud iam workload-identity-pools providers describe $PROVIDER_ID \
    --project=$PROJECT_ID \
    --location="global" \
    --workload-identity-pool=$POOL_ID

# List service account IAM bindings
gcloud iam service-accounts get-iam-policy $SERVICE_ACCOUNT_EMAIL
```

### Verify GCS Bucket

```bash
# List buckets in your project
gsutil ls -p $PROJECT_ID

# Check bucket permissions
gsutil iam get gs://$ANSIBLE_BUCKET_NAME
```

### Verify APIs

```bash
# List enabled APIs
gcloud services list --enabled --filter="name:compute OR name:storage OR name:iam"
```

## Troubleshooting

### Common Issues

1. **API not enabled**: Ensure all required APIs are enabled and wait for propagation
2. **Permission denied**: Verify service account has correct IAM roles
3. **Workload Identity issues**: Check attribute conditions and repository name
4. **Bucket access**: Ensure bucket name is globally unique and permissions are set

### Useful Commands

```bash
# Check current project
gcloud config get-value project

# List service accounts
gcloud iam service-accounts list

# Check project number
gcloud projects describe $PROJECT_ID --format="value(projectNumber)"

# Test service account permissions
gcloud auth list
```

## Security Considerations

- **Principle of Least Privilege**: Only grant minimum required permissions
- **Workload Identity**: Never use service account keys in GitHub secrets
- **Repository Protection**: Ensure branch protection rules are enabled
- **Secret Management**: Regularly rotate secrets and review access

## Next Steps

After completing these prerequisites:

1. ✅ Push code to the `main` branch to trigger the CI/CD pipeline
2. ✅ Monitor GitHub Actions workflow execution
3. ✅ Verify Terraform resources are created in GCP
4. ✅ Check Ansible playbook execution logs

## Resources

- [Workload Identity Federation Documentation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Google Cloud IAM Best Practices](https://cloud.google.com/iam/docs/using-iam-securely)