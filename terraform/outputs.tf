# -----------------------------------------------------------------------------
# COMPUTE INSTANCE PUBLIC IP ADDRESSES
# -----------------------------------------------------------------------------

output "controller_public_ip" {
  description = "Public IP address of the Ansible controller instance"
  value       = google_compute_instance.controller.network_interface[0].access_config[0].nat_ip
}

output "web_public_ip" {
  description = "Public IP address of the web server instance"
  value       = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}

output "ntp_public_ip" {
  description = "Public IP address of the NTP server instance"
  value       = google_compute_instance.ntp.network_interface[0].access_config[0].nat_ip
}

output "db_public_ip" {
  description = "Public IP address of the database server instance"
  value       = google_compute_instance.db.network_interface[0].access_config[0].nat_ip
}

output "controller_private_ip" {
  description = "Private IP address of the Ansible controller instance"
  value       = google_compute_instance.controller.network_interface[0].network_ip
}

output "web_private_ip" {
  description = "Private IP address of the web server instance"
  value       = google_compute_instance.web.network_interface[0].network_ip
}

output "ntp_private_ip" {
  description = "Private IP address of the NTP server instance"
  value       = google_compute_instance.ntp.network_interface[0].network_ip
}

output "db_private_ip" {
  description = "Private IP address of the database server instance"
  value       = google_compute_instance.db.network_interface[0].network_ip
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${google_compute_instance.web.network_interface[0].access_config[0].nat_ip}"
}

output "ansible_bucket_name" {
  description = "Name of the Google Cloud Storage bucket for Ansible configurations"
  value       = google_storage_bucket.ansible.name
}

output "ansible_bucket_url" {
  description = "Full URL of the Google Cloud Storage bucket"
  value       = google_storage_bucket.ansible.url
}

output "service_account_email" {
  description = "Email address of the Ansible service account"
  value       = google_service_account.ansible.email
}

output "project_info" {
  description = "Project and deployment information"
  value = {
    project_id = var.project_id
    region     = var.region
    zone       = var.zone
    network    = "default"
  }
}

output "rhel_image_info" {
  description = "Information about the RHEL image used"
  value = {
    image_name    = data.google_compute_image.rhel.name
    image_family  = data.google_compute_image.rhel.family
    image_project = var.rhel_image_project
    image_url     = data.google_compute_image.rhel.self_link
    creation_date = data.google_compute_image.rhel.creation_timestamp
  }
}

# -----------------------------------------------------------------------------
# ANSIBLE INVENTORY INFORMATION
# -----------------------------------------------------------------------------

output "ansible_inventory_ips" {
  description = "IP addresses formatted for Ansible inventory"
  value = {
    controller_ip = google_compute_instance.controller.network_interface[0].access_config[0].nat_ip
    web_ip        = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
    ntp_ip        = google_compute_instance.ntp.network_interface[0].access_config[0].nat_ip
    db_ip         = google_compute_instance.db.network_interface[0].access_config[0].nat_ip
  }
}