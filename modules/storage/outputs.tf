output "diagnostics_storage_account_endpoint" {
  value = azurerm_storage_account.sa_diagnostics.primary_blob_endpoint
}

output "vm_storage_account_id" {
  value = azurerm_storage_account.sa_vm_storage.id
}
