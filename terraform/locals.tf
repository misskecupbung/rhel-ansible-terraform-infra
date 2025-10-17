# =============================================================================
# LOCAL VALUES
# =============================================================================
# This file defines local values used throughout the Terraform configuration.
# Locals help reduce repetition and make the code more maintainable.

locals {
  # Common resource labels
  common_labels = merge(var.labels, {
    terraform   = "true"
    created_by  = "terraform"
    created_at  = timestamp()
    project     = "rhel-ansible-infra"
  })

  # Instance configurations
  instances = {
    controller = {
      name         = "controller"
      description  = "Ansible Controller Instance"
      machine_type = var.machine_type
      tags         = concat(var.tags, ["controller", "ansible-controller"])
      metadata = {
        enable-oslogin = "TRUE"
        startup-script = templatefile("${path.module}/startup-controller.sh", {
          BUCKET_NAME = var.ansible_bucket_name
        })
      }
    }
    
    web = {
      name         = "web"
      description  = "Web Server Instance"
      machine_type = var.machine_type
      tags         = concat(var.tags, ["web", "http-server"])
      metadata = {
        enable-oslogin = "TRUE"
      }
    }
    
    ntp = {
      name         = "ntp"
      description  = "NTP Server Instance"
      machine_type = var.machine_type
      tags         = concat(var.tags, ["ntp", "time-server"])
      metadata = {
        enable-oslogin = "TRUE"
      }
    }
    
    db = {
      name         = "db"
      description  = "Database Server Instance"
      machine_type = var.machine_type
      tags         = concat(var.tags, ["db", "database"])
      metadata = {
        enable-oslogin = "TRUE"
      }
    }
  }

  # Firewall rules configuration
  firewall_rules = {
    ssh = {
      name          = "allow-ssh"
      description   = "Allow SSH access to all instances"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]  # Restrict this in production
      target_tags   = var.tags
      ports         = ["22"]
      protocol      = "tcp"
    }
    
    http = {
      name          = "allow-http"
      description   = "Allow HTTP access to web servers"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["http-server"]
      ports         = ["80"]
      protocol      = "tcp"
    }
    
    ntp = {
      name          = "allow-ntp"
      description   = "Allow NTP access to time servers"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.128.0.0/9"]  # Internal network only
      target_tags   = ["time-server"]
      ports         = ["123"]
      protocol      = "udp"
    }
    
    postgresql = {
      name          = "allow-postgresql"
      description   = "Allow PostgreSQL access to database servers"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.128.0.0/9"]  # Internal network only
      target_tags   = ["database"]
      ports         = ["5432"]
      protocol      = "tcp"
    }
  }

  # Service account roles
  service_account_roles = [
    "roles/compute.instanceAdmin.v1",
    "roles/storage.objectAdmin",
    "roles/cloudbuild.builds.editor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]

  # Bucket configuration
  bucket_config = {
    name                        = var.ansible_bucket_name
    location                    = var.region
    force_destroy              = true
    uniform_bucket_level_access = true
    storage_class              = "STANDARD"
    
    lifecycle_rules = [
      {
        condition = {
          age = 30
        }
        action = {
          type = "Delete"
        }
      }
    ]
    
    versioning = {
      enabled = true
    }
  }
}