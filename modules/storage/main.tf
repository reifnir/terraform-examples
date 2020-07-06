data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

locals {
    # no dashes, must be unique across all customers/accounts
    storage_account_safe_resource_name_base = replace(var.resource_name_base, "-", "")
}

resource "azurerm_storage_account" "sa_diagnostics" {
  name                              = "sa${local.storage_account_safe_resource_name_base}diag"
  resource_group_name               = data.azurerm_resource_group.example.name
  location                          = data.azurerm_resource_group.example.location
  account_tier                      = "Standard"
  account_replication_type          = "GRS" # geo-redundant storage
  account_kind                      = "StorageV2"
  is_hns_enabled                    = false
  tags                              = var.tags
}

resource "azurerm_storage_account" "sa_vm_storage" {
  name                              = "sa${local.storage_account_safe_resource_name_base}vm"
  resource_group_name               = data.azurerm_resource_group.example.name
  location                          = data.azurerm_resource_group.example.location
  account_tier                      = "Premium"
  account_kind                      = "StorageV2"
  account_replication_type          = "LRS" # Locally-redundant storage
  is_hns_enabled                    = false
  tags                              = var.tags
}
