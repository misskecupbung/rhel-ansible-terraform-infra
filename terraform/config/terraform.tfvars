# =============================================================================
# TERRAFORM VARIABLES
# =============================================================================

# Note: project_id, ansible_bucket_name, and terraform_state_bucket 
# are now passed as variables from CI/CD pipeline

# Core Configuration
region     = "us-central1"
zone       = "us-central1-a"

# Compute Configuration
machine_type = "e2-medium"
network_name = "default"

# RHEL Configuration
rhel_image         = "family/rhel-10"
rhel_image_project = "rhel-cloud"

# Service Account
service_account_id = "ansible-controller"

# Cloud Build
cloud_build_trigger_name = "ansible-config-sync"

# Network Tags
tags = ["rhel", "ansible", "infrastructure"]

# Environment and Labels
environment = "main"
labels = {
  environment = "main"
  project     = "rhel-ansible-terraform"
  managed_by  = "terraform"
}