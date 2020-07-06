locals {
  vnet_cidr               = "10.0.0.0/8"
  app_gateway_subnet_cidr = "10.0.1.0/24"
  app_gateway_private_ip  = "10.0.1.4" # the first 3 ip addresses are reserved for internal Azure use
  vm_subnet_cidr          = "10.0.0.0/24"
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-${var.resource_name_base}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = [local.vnet_cidr]
  tags                 = var.tags
}

resource "azurerm_subnet" "vm" {
  name                 = "${var.resource_name_base}-vm-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [local.vm_subnet_cidr]
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.resource_name_base}-vm-availability-set"
  location                     = azurerm_resource_group.example.location
  resource_group_name          = azurerm_resource_group.example.name
  tags                         = var.tags
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}
