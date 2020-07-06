# Instead of relying on copypasta with these, consider generating the actual final terraform files programmatically.
# That way, you don't have to worry about all of the duplicated statements with slight config changes.
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "reifnirterraformstate"
    container_name       = "terraform-examples-prod"
    key                  = "infrastructure.tfstate"
  }
}
