output "network_id" {
  description = "VPC network id."
  value       = yandex_vpc_network.main.id
}

output "subnet_public_id" {
  description = "Public subnet id (no NAT default route on subnet itself)."
  value       = yandex_vpc_subnet.public.id
}


output "storage_service_account_id" {
  description = "Service account id for lakehouse / Object Storage (create keys manually)."
  value       = yandex_iam_service_account.storage.id
}


output "workload_vm_ids" {
  description = "Map of workload key to compute instance id."
  value       = { for k, v in yandex_compute_instance.workload : k => v.id }
}

output "workload_private_ips" {
  description = "Map of workload key to primary private IP."
  value       = { for k, v in yandex_compute_instance.workload : k => v.network_interface[0].ip_address }
}
