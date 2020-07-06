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
provider "template" {
  version = "~> 2.1"
  alias   = "apply"
}
provider "random" {
  version = "~> 2.2"
  alias   = "apply"
}

locals {

}

data "terraform_remote_state" "infrastructure" {
  backend = "azurerm"
  config = {
    storage_account_name = "reifnirterraformstate"
    container_name       = "terraform-examples-prod"
    key                  = "infrastructure.tfstate"
  }
}

module "vm" {
  source = "../../modules/vm"

  providers = {
    azurerm  = azurerm.apply
    template = template.apply
    random   = random.apply
  }

  resource_name_base  = data.terraform_remote_state.infrastructure.outputs.resource_base_name
  resource_group_name = data.terraform_remote_state.infrastructure.outputs.resource_group.name
  location            = data.terraform_remote_state.infrastructure.outputs.resource_group.location

  # Don't store the secrets such as password or certificate in outputs in infrastructure (or source for that matter) as it's stored unencrypted at rest
  health_check_hostname = "company.com"
  tls_cert_path         = "../../cert/cert-combined.pfx"
  tls_cert_password     = "derp"
  https_listening_port  = data.terraform_remote_state.infrastructure.outputs.https_listening_port

  tags = data.terraform_remote_state.infrastructure.outputs.tags

  data_disk_size_in_gb = 60
  vm_sku               = "Standard_F8s_v2"
  admin_username       = var.admin_username
  vm_id                = var.vm_id

  diag_storage_account_endpoint = data.terraform_remote_state.infrastructure.outputs.diagnostics_storage_account_endpoint

  app_gateway_backend_pool_id = data.terraform_remote_state.infrastructure.outputs.gateway_backend_pool_id
  vm_subnet_id                = data.terraform_remote_state.infrastructure.outputs.vm_subnet_id
  vm_availability_set_id      = data.terraform_remote_state.infrastructure.outputs.vm_availability_set_id
}


# data.terraform_remote_state.infrastructure.app_gateway_id
# data.terraform_remote_state.infrastructure.app_gateway_public_ip_address
# data.terraform_remote_state.infrastructure.diagnostics_storage_account_endpoint
# data.terraform_remote_state.infrastructure.resource_base_name
# data.terraform_remote_state.infrastructure.resource_group
# data.terraform_remote_state.infrastructure.tags
# data.terraform_remote_state.infrastructure.vm_storage_account_id
# data.terraform_remote_state.infrastructure.vm_subnet_id
