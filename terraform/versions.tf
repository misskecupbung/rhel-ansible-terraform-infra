# =============================================================================
# VERSION CONSTRAINTS
# =============================================================================

terraform {
  # Require minimum Terraform version
  required_version = ">= 1.6.0"

  required_providers {
    # Google Cloud Platform provider
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    
    # Google Cloud Beta provider (for beta features if needed)
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0"
    }

    # Random provider for generating unique names
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4"
    }

    # Local provider for local file operations
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }

    # Template provider for file templating
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2"
    }
  }
}