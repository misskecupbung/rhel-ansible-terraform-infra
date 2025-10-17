# =============================================================================
# TERRAFORM & PROVIDER CONFIGURATION
# =============================================================================

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 6.0"
    }
  }

  backend "gcs" {
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