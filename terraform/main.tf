locals {
  labels = {
    environment = "lab"
    managed_by  = "terraform"
  }
}

resource "google_service_account" "ansible" {
  account_id   = var.service_account_id
  display_name = "Ansible Controller SA"
}

# Grant SA permissions (compute + storage + cloudbuild)
resource "google_project_iam_member" "sa_compute" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}
resource "google_project_iam_member" "sa_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}
resource "google_project_iam_member" "sa_cloudbuild" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}
resource "google_project_iam_member" "sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}
resource "google_project_iam_member" "sa_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}

# Storage bucket to hold Ansible content
resource "google_storage_bucket" "ansible" {
  name          = var.ansible_bucket_name
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  labels = local.labels
}

# Pub/Sub topic for bucket notifications -> Cloud Build trigger
resource "google_pubsub_topic" "ansible_updates" {
  name   = "ansible-updates"
  labels = local.labels
}

# Notification from bucket to Pub/Sub (Object finalize & delete events)
resource "google_storage_notification" "ansible_bucket_notify" {
  bucket         = google_storage_bucket.ansible.name
  topic          = google_pubsub_topic.ansible_updates.id
  payload_format = "JSON_API_V1"
  event_types    = ["OBJECT_FINALIZE", "OBJECT_DELETE"]
}

# Cloud Build trigger listening to Pub/Sub
resource "google_cloudbuild_trigger" "ansible_sync" {
  name        = var.cloud_build_trigger_name
  description = "Run playbook when Ansible bucket changes"
  pubsub_config {
    topic    = google_pubsub_topic.ansible_updates.id
    service_account_email = google_service_account.ansible.email
    subscription = null
  }
  substitutions = {
    _ANSIBLE_BUCKET = google_storage_bucket.ansible.name
    _ZONE           = var.zone
  }
  filename = "cloudbuild.yaml"
}

# Firewall rule allowing SSH between controller and managed hosts (simplified)
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh-ansible"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rhel"]
}

# HTTP for web servers
resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

# PostgreSQL access (adjust source_ranges for production)
resource "google_compute_firewall" "postgres" {
  name    = "allow-postgres"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db"]
}

# NTP (UDP 123) - allow clients to reach ntp server
resource "google_compute_firewall" "ntp" {
  name    = "allow-ntp"
  network = var.network_name
  allow {
    protocol = "udp"
    ports    = ["123"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ntp"]
}

# Instance template data common
locals {
  instances = {
    controller = { machine_type = var.machine_type }
    web        = { machine_type = var.machine_type }
    ntp        = { machine_type = var.machine_type }
    db         = { machine_type = var.machine_type }
  }
}

# Create VMs
resource "google_compute_instance" "controller" {
  name         = "controller"
  machine_type = local.instances.controller.machine_type
  zone         = var.zone
  tags         = concat(var.tags, ["controller"])
  labels       = local.labels
  boot_disk {
    initialize_params {
      image = var.rhel_image
      size  = 30
    }
  }
  metadata = {
    BUCKET_NAME = var.ansible_bucket_name
    startup-script = file("${path.module}/startup-controller.sh")
  }
  network_interface {
    network = var.network_name
    access_config {}
  }
  service_account {
    email  = google_service_account.ansible.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Web server VM
resource "google_compute_instance" "web" {
  name         = "web"
  machine_type = local.instances.web.machine_type
  zone         = var.zone
  tags         = concat(var.tags, ["web"])
  labels       = local.labels
  boot_disk {
    initialize_params {
      image = var.rhel_image
      size  = 30
    }
  }
  network_interface {
    network = var.network_name
    access_config {}
  }
  service_account {
    email  = google_service_account.ansible.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# NTP server VM
resource "google_compute_instance" "ntp" {
  name         = "ntp"
  machine_type = local.instances.ntp.machine_type
  zone         = var.zone
  tags         = concat(var.tags, ["ntp"])
  labels       = local.labels
  boot_disk {
    initialize_params {
      image = var.rhel_image
      size  = 30
    }
  }
  network_interface {
    network = var.network_name
    access_config {}
  }
  service_account {
    email  = google_service_account.ansible.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# DB server VM
resource "google_compute_instance" "db" {
  name         = "db"
  machine_type = local.instances.db.machine_type
  zone         = var.zone
  tags         = concat(var.tags, ["db"])
  labels       = local.labels
  boot_disk {
    initialize_params {
      image = var.rhel_image
      size  = 50
    }
  }
  network_interface {
    network = var.network_name
    access_config {}
  }
  service_account {
    email  = google_service_account.ansible.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

output "controller_public_ip" { value = google_compute_instance.controller.network_interface[0].access_config[0].nat_ip }
output "bucket_name" { value = google_storage_bucket.ansible.name }
output "service_account_email" { value = google_service_account.ansible.email }
