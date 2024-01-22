variable "container_registry_name" {
  type = string
  description = "This defines the container registry name"
}

variable "container_registry_sku" {
  type = string
  description = "This defines the container registry sku"
}

variable "container_registry_admin_enabled" {
  type = bool
  default = false
  description = "This defines the container registry sku"
}

variable "service_principal_name" {
  type = string
  description = "This defines the AAD service principal name"
}

variable "container_registry_resource_group_name" {
  type = string
  description = "This defines the container registry resource group name"
}



