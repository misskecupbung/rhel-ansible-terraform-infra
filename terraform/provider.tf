# =============================================================================
# TERRAFORM & PROVIDER CONFIGURATION
# =============================================================================
# This file configures Terraform version requirements, backend, and providers.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }

  # Backend configuration
  backend "gcs" {
    # Configuration will be loaded from config/backend.hcl file
    # Usage: terraform init -backend-config=config/backend.hcl
  }
}

# -----------------------------------------------------------------------------
# GOOGLE CLOUD PROVIDER CONFIGURATION
# -----------------------------------------------------------------------------

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  default_labels = var.labels
}