variable "resource_group_name" {
    description = "Identifyer for the resource group in which new resources will be placed"
}

variable "resource_name_base" {
  description = "String of characters that are included in the names of many resources"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
}
