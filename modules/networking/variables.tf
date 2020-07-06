variable "resource_name_base" {
  description = "String of characters that are included in the names of many resources"
}

variable "resource_group_name" {
  description = "Identifyer for the resource group in which new resources will be placed"
}

variable "location" {
  description = "Azure region in which resources will be created"
}

variable "tags" {
  description = "Tags to associate with each newly-created resource"
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
  description = "This is the port to which the app gateway directs requests on machines in the backend address pool"
  default     = 8443
}
variable "gateway_request_timeout" {
  description = "The number of seconds before the app gateway times out on waiting for a response from a machine in the backend address pool"
  default     = 60
}