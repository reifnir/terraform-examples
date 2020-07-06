output "resource_group" {
  value = module.networking.resource_group
}

output "resource_base_name" {
  value = local.resource_base_name
}

output "vm_subnet_id" {
  value = module.networking.vm_subnet_id
}

output "app_gateway_public_ip_address" {
  value = module.networking.app_gateway_public_ip_address
}

output "gateway_backend_pool_id" {
  value = module.networking.gateway_backend_pool_id
}

output "vm_availability_set_id" {
  value = module.networking.vm_availability_set_id
}

output "diagnostics_storage_account_endpoint" {
  value = module.storage.diagnostics_storage_account_endpoint
}

output "vm_storage_account_id" {
  value = module.storage.vm_storage_account_id
}

output "tags" {
  value = local.tags
}

output "https_listening_port" {
  value = module.networking.https_listening_port
}