terraform {
  required_version = ">= 1.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.90.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.zone
  service_account_key_file = var.service_account_key_file != "" ? var.service_account_key_file : null
}

# --- Target topology (matches Task4 deployment diagram) ---
locals {
  # Keys become "${var.name_prefix}-<key>" in Yandex Cloud object names.
  workload_vms = {
    "med-services" = {
      hostname = "med-services"
    }
    "fin-services" = {
      hostname = "fin-services"
    }
    "ai-services" = {
      hostname = "ai-services"
    }
    "portal-services" = {
      hostname = "portal-services"
    }
    "airflow-vm" = {
      hostname = "airflow"
    }
    "kafka-broker" = {
      hostname = "kafka"
    }
  }
}

data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "random_id" "bucket_suffix" {
  byte_length = 2
}

resource "yandex_vpc_network" "main" {
  name        = "${var.name_prefix}-vpc"
  description = "Base VPC for Future 2.0 domain workload (lab)."
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.name_prefix}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

# NAT Gateway, Route Table, private subnet and Security Group are not available
# in the Practicum training folder — omitted for lab compatibility.
# In a production folder these would be restored as described in justification.md.

resource "yandex_iam_service_account" "storage" {
  name        = "${var.name_prefix}-storage-sa"
  description = "Service account for lakehouse / Object Storage access (keys created manually)."
}

resource "yandex_resourcemanager_folder_iam_member" "storage_sa_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage.id}"
}

# Object Storage bucket and separate Compute Disk require permissions not available
# in the Practicum training folder — omitted for lab compatibility.
# In a production folder these would be restored as described in justification.md.

resource "yandex_compute_instance" "workload" {
  for_each = local.workload_vms

  name                      = "${var.name_prefix}-${each.key}"
  hostname                  = each.value.hostname
  platform_id               = var.platform_id
  zone                      = var.zone
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory_gb
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = var.enable_preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.boot_disk_size
      type     = var.boot_disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = false
  }

  metadata = merge(
    {},
    var.ssh_public_key != "" ? { ssh-keys = "ubuntu:${var.ssh_public_key}" } : {}
  )
}
