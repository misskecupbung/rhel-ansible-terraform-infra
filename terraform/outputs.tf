output "controller_public_ip" { value = google_compute_instance.controller.network_interface[0].access_config[0].nat_ip }
output "web_public_ip" { value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip }
output "ntp_public_ip" { value = google_compute_instance.ntp.network_interface[0].access_config[0].nat_ip }
output "db_public_ip" { value = google_compute_instance.db.network_interface[0].access_config[0].nat_ip }
output "bucket_name" { value = google_storage_bucket.ansible.name }
output "service_account_email" { value = google_service_account.ansible.email }
