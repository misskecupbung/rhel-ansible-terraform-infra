# =============================================================================
# TERRAFORM VARIABLES
# =============================================================================

region     = "us-central1"
zone       = "us-central1-a"

machine_type = "e2-medium"
network_name = "default"

rhel_image         = "family/rhel-10"
rhel_image_project = "rhel-cloud"

service_account_id = "ansible-controller"

cloud_build_trigger_name = "ansible-config-sync"

tags = ["rhel", "ansible", "infrastructure"]

environment = "lab"
labels = {
  environment = "lab"
  project     = "rhel-ansible-terraform"
  managed_by  = "terraform"
}