# =============================================================================
# TERRAFORM VARIABLES
# =============================================================================

# Project Configuration
project_id = "your-project-id"
region     = "us-central1"
zone       = "us-central1-a"

# Environment Settings
environment = "main"

# Storage Configuration
ansible_bucket_name      = "your-project-ansible-configs"
terraform_state_bucket   = "your-project-terraform-state"

# Compute Configuration
machine_type = "e2-medium"

# Network Configuration
network_name    = "rhel-network"
subnet_name     = "rhel-subnet"
subnet_cidr     = "10.0.1.0/24"

# RHEL Configuration
rhel_image         = "family/rhel-10"
rhel_image_project = "rhel-cloud"

# Instance Configuration
instance_name = "rhel-instance"

# Security Configuration
allow_ssh_from_anywhere = true
ssh_key_file           = "~/.ssh/id_rsa.pub"

# Scaling Configuration (if using instance groups)
min_replicas = 1
max_replicas = 3

# Monitoring and Logging
enable_monitoring = true
enable_logging    = true

# Cost Management
preemptible = false  # Set to true for cost savings in non-production

# Labels and Tags
labels = {
  environment = "main"
  project     = "rhel-ansible-terraform"
  managed_by  = "terraform"
}