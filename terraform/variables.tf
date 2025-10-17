variable "project_id" { 
	type = string 
}
variable "region" { 
	type    = string  
	default = "us-central1" 
}
variable "zone" { 
	type    = string  
	default = "us-central1-a" 
}
variable "network_name" { 
	type    = string  
	default = "default" 
}
variable "ansible_bucket_name" { 
	type = string 
}
variable "machine_type" { 
	type    = string  
	default = "e2-medium" 
}
variable "tags" { 
	type    = list(string)  
	default = ["rhel","ansible"] 
}
variable "rhel_image" { 
	type    = string  
	default = "rhel-9-v20250101" 
}
variable "service_account_id" { 
	type    = string  
	default = "ansible-controller" 
}
variable "cloud_build_trigger_name" { 
	type    = string  
	default = "ansible-config-sync" 
}