# RHEL Ansible Terraform Infrastructure

Modern Infrastructure as Code solution for deploying and configuring RHEL instances on Google Cloud Platform with automated CI/CD.

## Overview

This project provides a complete infrastructure automation solution using:
- **Terraform** - Infrastructure provisioning on Google Cloud Platform
- **Ansible** - Configuration management and system hardening
- **GitHub Actions** - Automated CI/CD pipeline with Workload Identity Federation
- **RHEL 10** - Latest Red Hat Enterprise Linux with security best practices

## Architecture

**Infrastructure**: 4 RHEL VMs (controller, web, database, NTP server)  
**Automation**: Ansible controller with auto-sync from GCS bucket  
**Security**: Workload Identity Federation, no service account keys  
**Deployment**: GitOps workflow with environment-specific configurations

## Project Structure

```
rhel-ansible-terraform-infra/
├── terraform/
│   ├── config/terraform.tfvars  # Configuration variables
│   ├── main.tf                  # Infrastructure definitions
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output definitions
│   └── provider.tf              # Provider and backend configuration
├── .github/workflows/ci.yml     # Automated CI/CD pipeline
├── playbooks/site.yml           # Main Ansible playbook
├── roles/                       # Ansible roles for RHEL configuration
├── inventory/                   # Ansible inventory configuration
└── requirements.yml             # Ansible collections
```

## Quick Start

### 1. Prerequisites Setup
Complete the one-time setup following [PREREQUISITES.md](PREREQUISITES.md):
- Configure Google Cloud Project and APIs
- Set up Workload Identity Federation  
- Create GitHub repository secrets

### 2. Deploy Infrastructure

**Option A: Automatic (Recommended)**
```bash
# Push to main branch triggers automatic deployment
git push origin main
```

**Option B: Manual**
```bash
cd terraform

# Initialize with your project
terraform init \
  -backend-config="bucket=YOUR_PROJECT_ID-tfstate" \
  -backend-config="prefix=terraform"

# Plan and apply
terraform plan \
  -var="project_id=YOUR_PROJECT_ID" \
  -var="ansible_bucket_name=YOUR_PROJECT_ID-ansible" \
  -var="terraform_state_bucket=YOUR_PROJECT_ID-tfstate" \
  -var-file=config/terraform.tfvars

terraform apply
```

### 3. Monitor Deployment

```bash
# Check GitHub Actions workflow status
# View at: https://github.com/misskecupbung/rhel-ansible-terraform-infra/actions

# Check Cloud Build logs
gcloud builds list --limit=5

# SSH to controller and check logs
gcloud compute ssh controller --zone=us-central1-a
sudo journalctl -u google-startup-scripts.service -f
```

## CI/CD Pipeline

The GitHub Actions workflow provides fully automated infrastructure deployment:

### Pipeline Stages
1. **Validation** - Ansible lint, Terraform validation and formatting
2. **Planning** - Terraform plan with dynamic bucket names
3. **Deployment** - Infrastructure deployment (main branch only)
4. **Configuration** - Ansible configurations uploaded to GCS, triggering Cloud Build

### Required GitHub Secrets
- `GCP_PROJECT_ID` - Your Google Cloud Project ID
- `GCP_WORKLOAD_IDENTITY_PROVIDER` - Workload Identity Provider resource name
- `GCP_SERVICE_ACCOUNT_EMAIL` - Service Account email for authentication

### Dynamic Configuration
Bucket names are automatically generated from project ID:
- **Terraform state**: `{project-id}-tfstate`
- **Ansible configs**: `{project-id}-ansible`

## Ansible Roles

Each role handles specific RHEL system configuration:

| Role | Purpose | Key Features |
|------|---------|--------------|
| **chrony** | Time synchronization | NTP client configuration |
| **firewalld** | Firewall management | Port rules, service zones |
| **hostsfile** | /etc/hosts management | DNS resolution, host mapping |
| **httpd** | Web server | Apache installation, basic config |
| **ntpd** | NTP server | Time server for network |
| **postgresql** | Database server | PostgreSQL installation |
| **rhel_client** | Base RHEL config | SELinux, basic hardening |
| **ssh_hardening** | SSH security | Secure SSH configuration |

## Development

### Local Testing
```bash
# Validate Ansible code
ansible-lint --offline --skip-list galaxy

# Validate Terraform 
cd terraform
terraform validate
terraform fmt -check
```

### Manual Ansible Execution
```bash
# Run specific roles
ansible-playbook -i inventory/gcp_compute.yaml playbooks/site.yml --tags "chrony,firewalld"

# Check inventory
ansible-inventory -i inventory/gcp_compute.yaml --list
```

## Troubleshooting

### Common Issues
- **Terraform plan failures**: Check project ID and bucket names
- **Ansible lint errors**: Ensure ansible.posix collection is installed
- **SSH access**: Verify firewall rules and instance status
- **GCS permissions**: Confirm service account has storage access

### Useful Commands
```bash
# Check Cloud Build status
gcloud builds list --limit=5

# SSH to instances
gcloud compute ssh controller --zone=us-central1-a
gcloud compute ssh web --zone=us-central1-a

# View controller logs
gcloud compute ssh controller --zone=us-central1-a \
  --command='sudo journalctl -u google-startup-scripts.service -f'

# List GCS buckets
gsutil ls -p YOUR_PROJECT_ID
```

## Security Features

- **Workload Identity Federation** - No service account keys stored in GitHub
- **SELinux enforcement** - Security-Enhanced Linux enabled on all instances
- **SSH hardening** - Secure SSH configuration with key-based authentication
- **Firewall rules** - Restricted network access per service requirements
- **IAM least privilege** - Minimal permissions for service accounts

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test locally with ansible-lint and terraform validate
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.