variable "admin_username" {
  description = "Username for ssh"
}

variable "vm_id" {
  description = "Unique identifier for the given vm"
}

variable "app_gateway_backend_pool_id" {
  description = "Value of the app gateway backend pool id"
}

variable "data_disk_size_in_gb" {
  description = "size of data disk in gb"
  default     = 60
}

variable "resource_name_base" {
  description = "String of characters that are included in the names of many resources"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources are created"
}

variable "location" {
  description = "The location where resources are created"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
}

variable "diag_storage_account_endpoint" {
  description = "Storage account URL for boot diagnostics"
}

variable "vm_availability_set_id" {
  description = "Availability set that all managers belong to"

}

variable "vm_subnet_id" {
  description = "Subnet from which private IP addresses for VM will be provisioned"
}

variable "vm_sku" {
  description = "The SKU which should be used for this Virtual Machine, such as Standard_F2."
}

variable "tls_cert_path" {
  description = "Path to pkcs12 (pfx) certificate file"
}

variable "tls_cert_password" {
  description = "Password associated with the pkcs12 (pfx) certificate file"
}

variable "health_check_hostname" {
  description = "Value in the HOST header for checks to servers in the backend address pool"
}

variable "https_listening_port" {
  description = "The port at which https traffic will be listening"
}