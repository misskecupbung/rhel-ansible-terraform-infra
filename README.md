# RHEL Infrastructure Automation with Terraform & Ansible

A complete infrastructure-as-code solution that combines **Terraform** for Google Cloud Platform provisioning and **Ansible** for RHEL configuration management. This repository includes automated CI/CD pipelines with GitHub Actions for seamless deployment and management.

## 🏗️ Architecture Overview

This project provides:
- **Infrastructure Provisioning**: Terraform manages GCP resources (VMs, networking, storage)
- **Configuration Management**: Ansible handles RHEL system configuration and application deployment
- **CI/CD Pipeline**: GitHub Actions automates testing, validation, and deployment
- **Dynamic Inventory**: GCP Compute plugin for automatic host discovery
- **Security**: Workload Identity Federation for secure authentication

## ✨ Features
* Idempotent tasks: safe to re-run without unintended changes
* Structured roles for reuse and composition
* Separation of variables (defaults vs. environment / host overrides)
* Supports inventory grouping (e.g. `prod`, `stage`, `dev`)
* Extensible pattern for adding compliance or security hardening
* Easy ad‑hoc command examples for quick diagnostics

## ✅ Requirements

### Control Node (Local Development)
* **Python 3.13+** - Latest Python version with enhanced performance
* **Ansible >= 2.19** - Latest Ansible version with enhanced features and security
* **SSH access** to managed RHEL hosts (key-based authentication recommended)
* **Google Cloud SDK** (`gcloud`) for authentication and resource management

### Managed Nodes (Target Servers)
* **RHEL 10** (RHEL 8/9 also supported; other Enterprise Linux derivatives may work with minor adjustments)
* **Python 3** (installed by default on RHEL; bootstrap minimal images if needed)
* **OpenSSH server** enabled and configured

### Optional Development Tools
* **ansible-lint** for code quality and best practices validation
* **terraform** for infrastructure management
* **VS Code** with Ansible and Terraform extensions for enhanced development experience

## 📂 Repository Structure

```
rhel-ansible-terraform-infra/
├── README.md
├── PREREQUISITES.md              # Complete setup guide
├── requirements.txt             # Python dependencies
├── requirements.yml             # Ansible collections
├── cloudbuild.yaml              # Google Cloud Build configuration
├── .github/workflows/
│   └── ci.yml                   # GitHub Actions CI/CD pipeline
├── inventory/
│   ├── gcp_compute.yaml         # Dynamic GCP inventory
│   └── hosts                    # Static inventory (fallback)
├── group_vars/
│   └── all.yml                  # Global variables
├── playbooks/
│   └── site.yml                 # Main playbook
├── roles/                       # Ansible roles
│   ├── chrony/                  # Time synchronization
│   ├── firewalld/               # Firewall configuration
│   ├── hostsfile/               # /etc/hosts management
│   ├── httpd/                   # Web server setup
│   ├── ntpd/                    # NTP server configuration
│   ├── postgresql/              # Database server setup
│   ├── rhel_client/             # Base RHEL configuration
│   └── ssh_hardening/           # SSH security hardening
└── terraform/                   # Infrastructure as Code
    ├── main.tf                  # Core resources
    ├── variables.tf             # Input variables
    ├── outputs.tf               # Output values
    ├── provider.tf              # Provider configuration
    └── startup-controller.sh    # VM bootstrap script
```

## 🚀 Quick Start

### Prerequisites Setup
Before using this project, you must configure Google Cloud Platform and GitHub secrets. Follow the comprehensive guide:

📋 **[Complete Prerequisites Guide](PREREQUISITES.md)**

The prerequisites include:
- GCP project with billing enabled
- Workload Identity Federation setup
- Service account with required permissions
- GitHub repository secrets configuration

### Local Development Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/misskecupbung/rhel-ansible-terraform-infra.git
   cd rhel-ansible-terraform-infra
   ```

2. **Install dependencies**:
   ```bash
   # Ensure Python 3.13+ is installed
   # macOS: brew install python@3.13
   # Ubuntu/Debian: sudo apt install python3.13 python3.13-venv python3.13-pip
   # Or use pyenv: pyenv install 3.13.0 && pyenv global 3.13.0
   
   # Create virtual environment (recommended)
   python3.13 -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   
   # Install Python dependencies
   pip install --upgrade pip
   pip install -r requirements.txt
   
   # Install Ansible collections
   ansible-galaxy collection install -r requirements.yml
   
   # Install Terraform
   # macOS: brew install terraform
   # Or download from: https://terraform.io/downloads
   ```

3. **Configure authentication**:
   ```bash
   # Authenticate with Google Cloud
   gcloud auth login
   gcloud auth application-default login
   ```

## ⚡ Technology Stack Benefits

### **Python 3.13 Advantages**
- **Faster execution** with optimized bytecode interpreter  
- **Improved memory efficiency** for better resource utilization
- **Enhanced async/await performance** for concurrent operations
- **Better error messages** for easier debugging and development

### **Ansible 2.19 Features**
- **Enhanced security** with improved credential handling and vault encryption
- **Better performance** for large-scale deployments and complex playbooks  
- **Improved error reporting** and debugging capabilities with detailed stack traces
- **Enhanced collection management** and dependency resolution
- **Advanced templating** features with new filters and functions
- **Better cloud integration** with improved GCP, AWS, and Azure modules
- **RHEL 10 support** with latest system modules and package management

## 🏗️ Infrastructure Deployment

### 1. Deploy Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var "project_id=YOUR_GCP_PROJECT" -var "ansible_bucket_name=YOUR_UNIQUE_BUCKET"

# Apply the infrastructure
terraform apply -var "project_id=YOUR_GCP_PROJECT" -var "ansible_bucket_name=YOUR_UNIQUE_BUCKET"
```

### 2. Configure Ansible Inventory

The project uses **dynamic inventory** with the GCP Compute plugin:

```bash
# Test dynamic inventory
ansible-inventory -i inventory/gcp_compute.yaml --list

# Set environment variables (optional)
export ANSIBLE_GCP_PROJECT=your-project-id
export ANSIBLE_GCP_ZONE=us-central1-a
```

### 3. Deploy Configuration with Ansible

```bash
# Run the main playbook
ansible-playbook -i inventory/gcp_compute.yaml playbooks/site.yml

# Check mode (dry-run)
ansible-playbook -i inventory/gcp_compute.yaml playbooks/site.yml --check --diff

# Limit to specific hosts
ansible-playbook -i inventory/gcp_compute.yaml playbooks/site.yml --limit web_servers
```

## � Available Roles

| Role | Purpose | Key Features |
|------|---------|--------------|
| `rhel_client` | Base RHEL configuration | Packages, SELinux, timezone, baseline setup |
| `chrony` | Time synchronization | NTP client configuration (excludes NTP servers) |
| `ntpd` | NTP server | Dedicated time server setup |
| `firewalld` | Firewall management | Service-based rules, common ports |
| `httpd` | Web server | Apache installation, basic configuration |
| `postgresql` | Database server | PostgreSQL installation, initial setup |
| `hostsfile` | Host resolution | Dynamic `/etc/hosts` management |
| `ssh_hardening` | Security hardening | SSH configuration, key-based auth only |

## 🚀 CI/CD Pipeline

The project includes automated GitHub Actions workflows:

### Validation Pipeline (`.github/workflows/ci.yml`)
- **Ansible Lint**: Code quality and best practices
- **Terraform Validation**: Configuration syntax and formatting
- **Security Checks**: Basic validation of Terraform plans

### Deployment Pipeline
- **Automatic Deployment**: Triggered on push to `main` branch
- **Workload Identity**: Secure authentication without storing keys
- **Terraform Apply**: Infrastructure changes deployed automatically
- **Artifact Storage**: Terraform outputs stored for reference

### Manual Usage
```bash
# Run linting locally
ansible-lint

# Terraform validation
cd terraform
terraform fmt -check
terraform validate
```

## ⚙️ Configuration Management

### Variables Hierarchy
1. **Role Defaults**: `roles/<role>/defaults/main.yml` (lowest priority)
2. **Group Variables**: `group_vars/all.yml` (global configuration)
3. **Host Variables**: `host_vars/<hostname>.yml` (host-specific overrides)
4. **Extra Variables**: `-e` flag (highest priority)

### Key Configuration Files
- `group_vars/all.yml`: Global settings (timezone, packages, firewall rules)
- `inventory/gcp_compute.yaml`: Dynamic inventory configuration
- `requirements.yml`: Ansible collections dependencies

### Security & Secrets
```bash
# Encrypt sensitive files with Ansible Vault
ansible-vault encrypt group_vars/secrets.yml

# Edit encrypted files
ansible-vault edit group_vars/secrets.yml

# Run playbooks with vault
ansible-playbook -i inventory/gcp_compute.yaml playbooks/site.yml --ask-vault-pass
```

## 🧪 Testing & Quality Assurance

### Local Testing
```bash
# Syntax validation
ansible-playbook -i inventory/gcp_compute.yaml playbooks/site.yml --syntax-check

# Ansible linting
ansible-lint

# Terraform formatting
terraform fmt

# Terraform validation
cd terraform && terraform validate
```

### Continuous Integration
The GitHub Actions pipeline automatically:
- ✅ Validates Ansible syntax and best practices
- ✅ Checks Terraform configuration and formatting
- ✅ Runs security scans on infrastructure code
- ✅ Deploys changes on successful validation

## 🔒 Security Features

### Current Security Implementations
- **SSH Hardening**: Key-based authentication only, disabled root login
- **Firewall Management**: Service-based rules with `firewalld`
- **Workload Identity**: Keyless authentication for CI/CD
- **Network Segmentation**: GCP firewall rules for service isolation
- **Service Account**: Least-privilege IAM permissions

### Security Best Practices
- 🔐 **No SSH Keys in Code**: Uses GCP metadata for key management
- 🛡️ **Minimal IAM Roles**: Service accounts with only required permissions
- 🔒 **Encrypted Secrets**: Ansible Vault for sensitive configuration
- 📊 **Audit Trail**: All changes tracked through Git and CI/CD logs
- 🚫 **No Root Access**: Administrative tasks through sudo only

### Future Security Enhancements
- [ ] CIS RHEL benchmarks compliance
- [ ] Auditd configuration and log monitoring
- [ ] Automatic security updates with `dnf-automatic`
- [ ] SELinux policy customization
- [ ] Intrusion detection system (IDS) integration

## � Extending the Project

### Adding New Roles
```bash
# Create a new role
ansible-galaxy init roles/your_new_role

# Add to the main playbook
vim playbooks/site.yml
```

### Adding New Infrastructure
```bash
# Edit Terraform configuration
vim terraform/main.tf

# Plan and apply changes
cd terraform
terraform plan -var "project_id=YOUR_PROJECT"
terraform apply -var "project_id=YOUR_PROJECT"
```

### Environment-Specific Configurations
```bash
# Create environment-specific variable files
mkdir -p group_vars/production group_vars/staging

# Configure different settings per environment
echo "environment: production" > group_vars/production/main.yml
echo "environment: staging" > group_vars/staging/main.yml
```

## 🤝 Contributing

### Development Workflow
1. **Fork** the repository and create a feature branch
2. **Make changes** following the coding standards
3. **Test locally** using the provided testing commands
4. **Ensure CI passes** - all lints and validations must succeed
5. **Submit a PR** with detailed description of changes

### Coding Standards
- **Ansible**: Follow [Ansible best practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- **Terraform**: Use consistent naming, add comments, follow [HashiCorp style](https://www.terraform.io/docs/language/syntax/style.html)
- **Git**: Use conventional commit messages
- **Documentation**: Update README.md for significant changes

## 🗺️ Roadmap

### Current Status ✅
- ✅ Infrastructure provisioning with Terraform
- ✅ Configuration management with Ansible
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Dynamic inventory with GCP integration
- ✅ Security hardening and best practices

### Planned Enhancements 🔮
- [ ] **Multi-environment support** (dev/staging/prod)
- [ ] **Molecule testing framework** for role validation
- [ ] **Monitoring & observability** (Prometheus, Grafana)
- [ ] **Backup & disaster recovery** automation
- [ ] **Compliance reporting** (CIS, STIG)
- [ ] **Container orchestration** integration
- [ ] **Advanced networking** (VPN, service mesh)

## 🏗️ Infrastructure Components

This project provisions a complete RHEL infrastructure on Google Cloud Platform:

### Provisioned Resources
- **Ansible Controller VM**: Manages configuration across all hosts
- **Web Server**: RHEL instance with Apache HTTP server
- **Database Server**: RHEL instance with PostgreSQL
- **NTP Server**: Dedicated time synchronization service
- **GCS Bucket**: Stores Ansible configurations and artifacts
- **Networking**: VPC, firewall rules, and service connectivity
- **IAM**: Service accounts with least-privilege permissions

### Automation Flow
1. **Infrastructure Deployment**: Terraform provisions GCP resources
2. **Configuration Sync**: Cloud Build monitors bucket changes
3. **Automatic Configuration**: Ansible controller applies changes
4. **Drift Correction**: Periodic runs ensure consistency
5. **CI/CD Integration**: GitHub Actions manages the entire lifecycle

### Cloud Build Integration
The `cloudbuild.yaml` configuration enables automatic configuration updates:
- **Trigger**: Activated on GCS bucket object changes
- **Sync Process**: Securely copies configurations to controller
- **Execution**: Runs Ansible playbooks across all managed hosts
- **Monitoring**: Provides logs and status of all operations


## 📚 Additional Resources

### Documentation
- 📋 **[Prerequisites Setup Guide](PREREQUISITES.md)** - Complete GCP and GitHub setup
- 🏗️ **[Terraform Configuration](terraform/)** - Infrastructure as Code documentation
- 🔧 **[Ansible Roles](roles/)** - Individual role documentation and variables
- 🚀 **[CI/CD Pipeline](.github/workflows/ci.yml)** - Automation workflow details

### External Resources
- [Google Cloud Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Terraform Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🆘 Support & Troubleshooting

### Common Issues
- **Authentication Errors**: Verify Workload Identity Federation setup
- **Terraform Apply Failures**: Check GCP project permissions and quotas
- **Ansible Connection Issues**: Validate SSH keys and firewall rules
- **Dynamic Inventory Problems**: Ensure GCP credentials and project access

### Getting Help
- 🐛 **Bug Reports**: [Open an issue](https://github.com/misskecupbung/rhel-ansible-terraform-infra/issues)
- 💡 **Feature Requests**: Use GitHub Discussions
- 📖 **Documentation**: Check the [Prerequisites Guide](PREREQUISITES.md)
- 🔧 **Configuration**: Review role-specific documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**⭐ Star this repository** if you find it helpful! Contributions and feedback are always welcome.

