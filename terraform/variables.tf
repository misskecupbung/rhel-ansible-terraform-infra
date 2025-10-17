# =============================================================================
# TERRAFORM VARIABLES
# =============================================================================

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "ansible_bucket_name" {
  description = "Name of the GCS bucket for Ansible configurations (must be globally unique)"
  type        = string
  validation {
    condition     = length(var.ansible_bucket_name) > 0 && can(regex("^[a-z0-9][a-z0-9-_]*[a-z0-9]$", var.ansible_bucket_name))
    error_message = "Bucket name must be lowercase, start and end with alphanumeric characters."
  }
}

variable "terraform_state_bucket" {
  description = "Name of the GCS bucket for Terraform state (must be globally unique)"
  type        = string
  validation {
    condition     = length(var.terraform_state_bucket) > 0 && can(regex("^[a-z0-9][a-z0-9-_]*[a-z0-9]$", var.terraform_state_bucket))
    error_message = "Terraform state bucket name must be lowercase, start and end with alphanumeric characters."
  }
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
  default     = "us-central1"
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be a valid GCP region format (e.g., us-central1)."
  }
}

variable "zone" {
  description = "The GCP zone for zonal resources (must be within the specified region)"
  type        = string
  default     = "us-central1-a"
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.zone))
    error_message = "Zone must be a valid GCP zone format (e.g., us-central1-a)."
  }
}

variable "network_name" {
  description = "Name of the VPC network to use for compute instances"
  type        = string
  default     = "default"
}

variable "machine_type" {
  description = "Machine type for compute instances"
  type        = string
  default     = "e2-medium"
  validation {
    condition = contains([
      "e2-micro", "e2-small", "e2-medium", "e2-standard-2", "e2-standard-4",
      "n1-standard-1", "n1-standard-2", "n1-standard-4", "n2-standard-2"
    ], var.machine_type)
    error_message = "Machine type must be a valid GCP machine type."
  }
}

variable "rhel_image" {
  description = "RHEL image to use for compute instances (family/rhel-10 or specific image name)"
  type        = string
  default     = "family/rhel-10"
  validation {
    condition     = can(regex("^(family/rhel-[0-9]+|rhel-[0-9]+-v[0-9]+|projects/.*/global/images/.*)$", var.rhel_image))
    error_message = "RHEL image must be a family (family/rhel-10), specific image (rhel-10-v20250101), or full image path."
  }
}

variable "rhel_image_project" {
  description = "Project ID where the RHEL images are stored"
  type        = string
  default     = "rhel-cloud"
}

variable "tags" {
  description = "Network tags to apply to compute instances"
  type        = list(string)
  default     = ["rhel", "ansible", "infrastructure"]
}

variable "service_account_id" {
  description = "ID for the Ansible service account"
  type        = string
  default     = "ansible-controller"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "Service account ID must be 6-30 characters, lowercase letters, digits, and hyphens."
  }
}

variable "cloud_build_trigger_name" {
  description = "Name for the Cloud Build trigger"
  type        = string
  default     = "ansible-config-sync"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "lab"
  validation {
    condition     = contains(["dev", "staging", "prod", "lab"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, lab."
  }
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    environment = "lab"
    managed_by  = "terraform"
    project     = "rhel-ansible-infra"
  }
}