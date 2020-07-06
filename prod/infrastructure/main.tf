locals {
  resource_base_name = "tf-examples-prod"
  resource_group_name = "rg-${local.resource_base_name}"
  vnet_name           = "vnet-${local.resource_base_name}"

  location = "East US"
  tags = {
    Environemnt = "Prod"
    Application = "Terraform Examples"
  }
}

# Terraform provider for remote state
provider "azurerm" {
  version         = "~> 2.17"
  subscription_id = "58178b20-a04e-476f-90d7-1611a3025a3b" //subscription 1
  features {}
}

# Terraform provider that will be used for all new resources (showing that you can use more than one subscription at a time)
provider "azurerm" {
  version         = "~> 2.17"
  subscription_id = "75f175d3-867d-4d01-a817-4b36b9dd91a5" //subscription 2
  alias           = "apply"
  features {}
}

module "networking" {
  source = "../../modules/networking"
  providers = {
    azurerm = azurerm.apply
  }
  resource_name_base    = local.resource_base_name
  resource_group_name   = local.resource_group_name
  location              = local.location
  tls_cert_path         = "../../cert/cert-combined.pfx"
  tls_cert_password     = "derp"
  health_check_hostname = "company.com"
  tags                  = local.tags
}

module "storage" {
  source = "../../modules/storage"
  providers = {
    azurerm = azurerm.apply
  }
  resource_name_base  = local.resource_base_name
  resource_group_name = module.networking.resource_group.name
  tags                = local.tags
}
