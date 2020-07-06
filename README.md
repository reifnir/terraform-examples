# Terraform Examples

## Notes
* In order to reach the terraform state you'll need to have a few environment variables populated for storing state up in Azure blob storage
  * 
  * ARM_ACCESS_KEY (`az storage account keys list...`)
  * ARM_SUBSCRIPTION_ID (might only be necessary if you're using more than one Azure subscription)
  * ARM_TENANT_ID (`az account show`)

* The storage account and container both need to already exist. The blob itself will be made by terraform.