output "resource_group" {
  # Return the whole resource group instead of just the name (just to show that you can)
  value = azurerm_resource_group.example
}

output "vm_subnet_id" {
  value = azurerm_subnet.vm.id
}

output "app_gateway_public_ip_address" {
  value = azurerm_public_ip.app_gateway.ip_address
}

output "gateway_backend_pool_id" {
  value = "${azurerm_application_gateway.app_gateway.id}/backendAddressPools/${local.app_gateway_backend_pool_name}"
}

output "vm_availability_set_id" {
  value = azurerm_availability_set.vm.id
}

output "https_listening_port" {
  value = var.https_listening_port
}

# output "app_gateway_id" {
#   value = azurerm_application_gateway.app_gateway.id
# }
