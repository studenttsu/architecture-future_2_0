variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud cloud id (see `yc config list` or console)."
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud folder id where resources are created."
}

variable "zone" {
  type        = string
  description = "Availability zone, e.g. ru-central1-a."
  default     = "ru-central1-a"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
  default     = "future20-lab"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for public subnet (no default route via NAT)."
  default     = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for private subnet (default route via NAT gateway)."
  default     = "10.10.2.0/24"
}

variable "image_family" {
  type        = string
  description = "Compute image family for boot disk."
  default     = "ubuntu-2204-lts"
}

variable "platform_id" {
  type        = string
  description = "CPU platform (standard-v3 is a common default in Yandex Cloud)."
  default     = "standard-v3"
}

variable "vm_cores" {
  type        = number
  description = "vCPU count for the application VM."
  default     = 2
}

variable "vm_memory_gb" {
  type        = number
  description = "RAM in GB for the application VM."
  default     = 4
}

variable "boot_disk_size" {
  type        = number
  description = "Boot disk size in GB."
  default     = 20
}

variable "boot_disk_type" {
  type        = string
  description = "Boot disk type (network-hdd is cost-effective for labs)."
  default     = "network-hdd"
}

variable "data_disk_size" {
  type        = number
  description = "Secondary data disk size in GB (e.g. for logs or local cache)."
  default     = 32
}

variable "data_disk_type" {
  type        = string
  description = "Secondary disk type."
  default     = "network-hdd"
}

variable "trusted_admin_cidr" {
  type        = string
  description = "CIDR allowed to SSH to the VM (VM has no public IP; use VPN/bastion in real setups)."
  default     = "10.0.0.0/8"
}

variable "ssh_public_key" {
  type        = string
  description = "Optional OpenSSH public line for ubuntu user (empty to skip)."
  default     = ""
  sensitive   = false
}

variable "enable_preemptible" {
  type        = bool
  description = "Use preemptible VM to reduce lab cost."
  default     = true
}

variable "service_account_key_file" {
  type        = string
  description = "Path to Yandex Cloud service account JSON key file. Set in terraform.tfvars or via TF_VAR_service_account_key_file env."
  default     = ""
}

variable "lakehouse_bucket_max_size_bytes" {
  type        = number
  description = "Max bucket size in bytes (Object Storage lakehouse raw zone)."
  default     = 10737418240 # 10 GiB
}
