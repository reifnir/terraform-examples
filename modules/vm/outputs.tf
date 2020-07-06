output "hostname" {
  value = local.vm_hostname
}

output "private_ip_address" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "public_ip_address" {
  value = azurerm_public_ip.vm.ip_address
}
