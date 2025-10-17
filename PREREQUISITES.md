# Prerequisites Setup Guide# Prerequisites Setup Guide

Complete setup instructions for the RHEL Ansible Terraform Infrastructure project.This document provides step-by-step instructions to set up all the prerequisites for the RHEL Ansible Terraform Infrastructure CI/CD pipeline.


## Required Tools## Overview

Install the following tools on your local machine:This project uses:

- **Terraform** for infrastructure provisioning on Google Cloud Platform

### 1. Google Cloud SDK- **Ansible** for configuration management

```bash- **GitHub Actions** for CI/CD automation

# macOS- **Workload Identity Federation** for secure authentication

brew install google-cloud-sdk

## Requirements

# Ubuntu/Debian

curl https://sdk.cloud.google.com | bash- Google Cloud Platform account with billing enabled

- `gcloud` CLI installed and authenticated

# After installation- GitHub repository access

gcloud auth login- Basic knowledge of Terraform and Ansible

gcloud auth application-default login

```## Setup Instructions



### 2. Terraform### 1. Environment Variables Setup

```bash

# macOSFirst, set up your environment variables. Replace the placeholder values with your actual project details:

brew tap hashicorp/tap

brew install hashicorp/tap/terraform```bash

# Set your project variables

# Linuxexport PROJECT_ID="your-project-id"                    # Replace with your GCP project ID

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpgexport PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.listexport POOL_ID="github-actions-pool"

sudo apt update && sudo apt install terraformexport PROVIDER_ID="github-actions-provider"

```export SERVICE_ACCOUNT_NAME="github-actions-sa"

export GITHUB_REPO="misskecupbung/rhel-ansible-terraform-infra"

### 3. Python and Ansibleexport ANSIBLE_BUCKET_NAME="your-ansible-bucket-name"  # Replace with unique bucket name

```bashexport REGION="us-central1"                            # Change to your preferred region

# Ensure Python 3.13+```

python3 --version

### 2. Set Active Project and Enable APIs

# Install Ansible

pip install ansible>=2.19```bash

# Set the current project

# Install required collectionsgcloud config set project $PROJECT_ID

ansible-galaxy collection install google.cloud community.general

```# Enable required Google Cloud APIs

gcloud services enable iamcredentials.googleapis.com

## Google Cloud Setupgcloud services enable sts.googleapis.com

gcloud services enable cloudresourcemanager.googleapis.com

### 1. Set Environment Variablesgcloud services enable compute.googleapis.com

```bashgcloud services enable storage.googleapis.com

export PROJECT_ID="your-project-id"gcloud services enable iam.googleapis.com

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")```

export REGION="us-central1"

export SERVICE_ACCOUNT_NAME="github-actions-sa"**Wait for APIs to be fully enabled (may take a few minutes)**

export GITHUB_REPO="your-username/your-repo-name"

```### 3. Create Service Account



### 2. Enable Required APIs```bash

```bash# Create the service account for GitHub Actions

gcloud config set project $PROJECT_IDgcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \

    --display-name="GitHub Actions Service Account" \

gcloud services enable iamcredentials.googleapis.com \    --description="Service account for GitHub Actions CI/CD"

  sts.googleapis.com \

  cloudresourcemanager.googleapis.com \# Get the service account email

  compute.googleapis.com \export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

  storage.googleapis.com \```

  iam.googleapis.com \

  cloudbuild.googleapis.com### 4. Grant IAM Roles to Service Account

```

```bash

### 3. Create Service Account# Core roles for Terraform operations

```bashgcloud projects add-iam-policy-binding $PROJECT_ID \

# Create service account    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \

gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \    --role="roles/compute.admin"

  --display-name="GitHub Actions Service Account"

gcloud projects add-iam-policy-binding $PROJECT_ID \

# Get service account email    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \

export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"    --role="roles/storage.admin"



# Assign required rolesgcloud projects add-iam-policy-binding $PROJECT_ID \

gcloud projects add-iam-policy-binding $PROJECT_ID \    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \

  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \    --role="roles/iam.serviceAccountUser"

  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \

gcloud projects add-iam-policy-binding $PROJECT_ID \    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \

  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \    --role="roles/resourcemanager.projectIamAdmin"

  --role="roles/storage.admin"

# Network and security roles

gcloud projects add-iam-policy-binding $PROJECT_ID \gcloud projects add-iam-policy-binding $PROJECT_ID \

  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \

  --role="roles/iam.serviceAccountUser"    --role="roles/compute.networkAdmin"

```

gcloud projects add-iam-policy-binding $PROJECT_ID \

### 4. Setup Workload Identity Federation    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \

```bash    --role="roles/compute.securityAdmin"

# Create workload identity pool```

gcloud iam workload-identity-pools create "github-actions-pool" \

  --location="global" \### 5. Create Workload Identity Pool

  --display-name="GitHub Actions Pool"

```bash

# Create workload identity provider# Create the workload identity pool

gcloud iam workload-identity-pools providers create-oidc "github-actions-provider" \gcloud iam workload-identity-pools create $POOL_ID \

  --location="global" \    --project=$PROJECT_ID \

  --workload-identity-pool="github-actions-pool" \    --location="global" \

  --display-name="GitHub Actions Provider" \    --display-name="GitHub Actions Pool" \

  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \    --description="Workload Identity Pool for GitHub Actions"

  --issuer-uri="https://token.actions.githubusercontent.com"```



# Allow GitHub Actions to impersonate service account### 6. Create Workload Identity Provider

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \

  --role="roles/iam.workloadIdentityUser" \```bash

  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/$GITHUB_REPO"# Create the OIDC provider for GitHub Actions

```gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID \

    --project=$PROJECT_ID \

### 5. Create Storage Buckets    --location="global" \

```bash    --workload-identity-pool=$POOL_ID \

# Create Terraform state bucket    --display-name="GitHub Actions Provider" \

export TERRAFORM_STATE_BUCKET="${PROJECT_ID}-terraform-state"    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \

gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$TERRAFORM_STATE_BUCKET    --attribute-condition="assertion.repository_owner == 'misskecupbung'" \

    --issuer-uri="https://token.actions.githubusercontent.com"

# Create Ansible configurations bucket```

export ANSIBLE_BUCKET="${PROJECT_ID}-ansible-configs"

gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$ANSIBLE_BUCKET### 7. Configure Service Account Impersonation



# Enable versioning for state bucket```bash

gsutil versioning set on gs://$TERRAFORM_STATE_BUCKET# Allow GitHub Actions to impersonate the service account

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \

# Set permissions    --project=$PROJECT_ID \

gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://$TERRAFORM_STATE_BUCKET    --role="roles/iam.workloadIdentityUser" \

gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://$ANSIBLE_BUCKET    --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/attribute.repository/$GITHUB_REPO"

``````



## GitHub Repository Setup### 8. Create Google Cloud Storage Buckets



### 1. Required SecretsCreate the required storage buckets for Terraform state and Ansible configurations:



Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):```bash

# Create Terraform state bucket

```bashexport TERRAFORM_STATE_BUCKET="${PROJECT_ID}-terraform-state"

# Display values for GitHub secretsgsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$TERRAFORM_STATE_BUCKET

echo "Add these secrets to your GitHub repository:"

echo ""# Create Ansible configuration bucket

echo "GCP_PROJECT_ID: $PROJECT_ID"export ANSIBLE_BUCKET="${PROJECT_ID}-ansible-configs"

echo "GCP_SERVICE_ACCOUNT_EMAIL: $SERVICE_ACCOUNT_EMAIL"gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$ANSIBLE_BUCKET

echo "GCP_WORKLOAD_IDENTITY_PROVIDER: projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider"

echo "ANSIBLE_BUCKET_NAME: $ANSIBLE_BUCKET"# Enable versioning for state bucket (recommended)

```gsutil versioning set on gs://$TERRAFORM_STATE_BUCKET



### 2. Update Configuration Files# Set appropriate permissions for both buckets

gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://$TERRAFORM_STATE_BUCKET

After creating buckets, update these files:gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://$ANSIBLE_BUCKET



**terraform/config/backend.hcl:**# Verify buckets were created

```hclgsutil ls -p $PROJECT_ID

bucket = "your-project-terraform-state"```

prefix = "terraform/state"

```**Important**: After creating the buckets, update the bucket names in:

- `terraform/config/backend.hcl` 

**terraform/config/terraform.tfvars:**- `terraform/config/terraform.tfvars`

```hcl

project_id = "your-project-id"### 9. Get GitHub Secrets Values

ansible_bucket_name = "your-project-ansible-configs"

terraform_state_bucket = "your-project-terraform-state"Run these commands to get the values you need to add as GitHub secrets:

# ... other variables

``````bash

# Display all required secret values

## Verificationecho "=================================================="

echo "GitHub Repository Secrets Configuration"

Test your setup:echo "=================================================="

echo ""

```bashecho "GCP_WORKLOAD_IDENTITY_PROVIDER:"

# Test gcloud authenticationecho "projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"

gcloud auth listecho ""

echo "GCP_SERVICE_ACCOUNT_EMAIL:"

# Test Terraformecho "$SERVICE_ACCOUNT_EMAIL"

cd terraformecho ""

terraform init -backend-config=config/backend.hclecho "GCP_PROJECT_ID:"

terraform validateecho "$PROJECT_ID"

echo ""

# Test Ansibleecho "ANSIBLE_BUCKET_NAME:"

ansible --versionecho "$ANSIBLE_BUCKET"

ansible-inventory -i inventory/gcp_compute.yaml --listecho ""

```echo "TERRAFORM_STATE_BUCKET (configured in backend.hcl):"

echo "$TERRAFORM_STATE_BUCKET"

## Troubleshootingecho ""

echo "Optional configuration (can use defaults):"

### Common Issuesecho "RHEL_IMAGE_NAME: family/rhel-10"

echo "RHEL_IMAGE_PROJECT: rhel-cloud"

1. **Permission Denied**: Ensure service account has required rolesecho "GCP_REGION: us-central1"

2. **Bucket Already Exists**: Use globally unique bucket namesecho "GCP_ZONE: us-central1-a"

3. **API Not Enabled**: Run the enable APIs command againecho "=================================================="

4. **Workload Identity Issues**: Verify repository name matches exactly```



### Useful Commands### 10. Add Secrets to GitHub Repository



```bash1. Navigate to your GitHub repository

# Check enabled APIs2. Go to **Settings** → **Secrets and variables** → **Actions**

gcloud services list --enabled3. Click **New repository secret**

4. Add each of the following secrets with the values from step 9:

# List service accounts

gcloud iam service-accounts list| Secret Name | Required | Description |

|-------------|----------|-------------|

# Check workload identity pools| `GCP_WORKLOAD_IDENTITY_PROVIDER` | ✅ | Full resource name of the Workload Identity Provider |

gcloud iam workload-identity-pools list --location=global| `GCP_SERVICE_ACCOUNT_EMAIL` | ✅ | Email of the service account created above |

| `GCP_PROJECT_ID` | ✅ | Your Google Cloud Project ID |

# Verify bucket access| `ANSIBLE_BUCKET_NAME` | ✅ | Name of the GCS bucket for Ansible artifacts |

gsutil ls -p $PROJECT_ID| `RHEL_IMAGE_NAME` | 🔸 | RHEL image name (default: `family/rhel-10`) |

```| `RHEL_IMAGE_PROJECT` | 🔸 | Project containing RHEL images (default: `rhel-cloud`) |

| `GCP_REGION` | 🔸 | GCP region for resources (default: `us-central1`) |

For additional help, check the [README.md](README.md) or open an issue in the repository.| `GCP_ZONE` | 🔸 | GCP zone for resources (default: `us-central1-a`) |

**Legend**: ✅ Required • 🔸 Optional (has default values)

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