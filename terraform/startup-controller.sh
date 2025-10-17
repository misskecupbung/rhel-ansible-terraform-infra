#!/usr/bin/env bash
set -euo pipefail

# Basic updates and tooling
yum -y update || dnf -y update

# Enable EPEL if needed (commented for pure RHEL subscription environments)
# dnf -y install epel-release

dnf -y install python3 python3-pip git curl
pip3 install --upgrade pip
pip3 install ansible>=2.19

# Variables (will be substituted via Terraform templatefile if needed)
BUCKET_NAME="${BUCKET_NAME:-}" # set by metadata or terraform
ANSIBLE_DIR=/opt/ansible
mkdir -p "$ANSIBLE_DIR"
cd "$ANSIBLE_DIR"

# Initial sync from GCS bucket (public or with attached SA permissions)
if ! command -v gsutil >/dev/null 2>&1; then
  echo "gsutil not found; installing google-cloud-sdk"
  dnf -y install dnf-plugins-core || true
  cat >/etc/yum.repos.d/google-cloud-sdk.repo <<'REPO'
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
REPO
  dnf -y install google-cloud-sdk || echo "Failed to install google-cloud-sdk"
fi

/usr/bin/gsutil -m rsync -r "gs://$BUCKET_NAME" "$ANSIBLE_DIR" || echo "Initial rsync failed"

# Install any collections/roles specified
if [ -f requirements.yml ]; then
  ansible-galaxy install -r requirements.yml || echo "Galaxy install failed"
fi

# Write dynamic inventory from instance metadata (placeholder)
cat > inventory/hosts <<'EOF'
[controller]
localhost ansible_connection=local
EOF

# Run main playbook if present
if [ -f playbooks/site.yml ]; then
  ansible-playbook playbooks/site.yml || echo "Initial apply failed"
fi

# Cron job to pull updates every 5 minutes
cat > /etc/cron.d/ansible-sync <<CRON
*/5 * * * * root /usr/bin/gsutil -m rsync -r gs://$BUCKET_NAME $ANSIBLE_DIR && ansible-playbook $ANSIBLE_DIR/playbooks/site.yml > /var/log/ansible-sync.log 2>&1
CRON

systemctl restart crond || service crond restart || true

echo "Controller bootstrap complete"
