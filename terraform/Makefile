# =============================================================================
# TERRAFORM MAKEFILE
# =============================================================================
# This Makefile provides convenient commands for managing Terraform.
#
# Usage Examples:
#   make init          # Initialize Terraform
#   make plan          # Plan changes
#   make apply         # Apply changes
#   make destroy       # Destroy infrastructure

# Color codes for output
RED    := \033[31m
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
RESET  := \033[0m

# Helper function to print colored messages
define print_message
	@echo "$(BLUE)==> $(1)$(RESET)"
endef

# =============================================================================
# VALIDATION COMMANDS
# =============================================================================

.PHONY: validate fmt lint

validate: ## Validate Terraform configuration
	$(call print_message,Validating Terraform configuration...)
	@terraform init -backend=false
	@terraform validate
	@echo "$(GREEN)✅ Terraform validation passed$(RESET)"

fmt: ## Format Terraform files
	$(call print_message,Formatting Terraform files...)
	@terraform fmt -recursive
	@echo "$(GREEN)✅ Terraform files formatted$(RESET)"

lint: validate fmt ## Run all linting checks
	$(call print_message,Running Terraform linting...)
	@echo "$(GREEN)✅ All linting checks passed$(RESET)"

# =============================================================================
# TERRAFORM OPERATIONS
# =============================================================================

.PHONY: init plan apply destroy

init: ## Initialize Terraform
	$(call print_message,Initializing Terraform...)
	@terraform init -backend-config=config/backend.hcl

plan: ## Plan Terraform changes
	$(call print_message,Planning Terraform changes...)
	@terraform plan -var-file=config/terraform.tfvars

apply: ## Apply Terraform changes
	$(call print_message,Applying Terraform changes...)
	@echo "$(YELLOW)⚠️  You are about to apply changes to your infrastructure$(RESET)"
	@read -p "Are you sure? [y/N]: " confirm; [ "$$confirm" = "y" ] || exit 1
	@terraform apply -var-file=config/terraform.tfvars

destroy: ## Destroy Terraform infrastructure (BE CAREFUL!)
	$(call print_message,Destroying Terraform infrastructure...)
	@echo "$(RED)🚨 DANGER: You are about to DESTROY your infrastructure!$(RESET)"
	@echo "$(RED)This action is IRREVERSIBLE and will delete ALL resources!$(RESET)"
	@read -p "Type 'destroy-confirm' to confirm: " confirm; [ "$$confirm" = "destroy-confirm" ] || exit 1
	@terraform destroy -var-file=config/terraform.tfvars

output: ## Show Terraform outputs
	$(call print_message,Terraform outputs...)
	@terraform output

# =============================================================================
# UTILITY COMMANDS
# =============================================================================

.PHONY: clean workspace-list workspace-show help

clean: ## Clean temporary files and caches
	$(call print_message,Cleaning temporary files...)
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@rm -f terraform.tfstate*
	@rm -f tfplan*
	@echo "$(GREEN)✅ Cleanup completed$(RESET)"

workspace-list: ## List all Terraform workspaces
	@terraform workspace list

workspace-show: ## Show current workspace
	@terraform workspace show

help: ## Show this help message
	@echo "$(BLUE)Terraform Management$(RESET)"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  $(YELLOW)%-20s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(BLUE)Configuration Files:$(RESET)"
	@echo "  config/backend.hcl       - Backend configuration"
	@echo "  config/terraform.tfvars  - Variable values"
	@echo ""
	@echo "$(BLUE)Usage Examples:$(RESET)"
	@echo "  make init && make plan && make apply"
	@echo "  make plan   # Review changes before applying"
	@echo "  make output # Show current infrastructure outputs"

# Default target
.DEFAULT_GOAL := help