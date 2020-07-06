terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "reifnirterraformstate"
    container_name       = "terraform-examples-prod"
    # Key passed in at command line for each vm separately
  }
}
