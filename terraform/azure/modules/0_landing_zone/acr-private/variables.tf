variable "resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "acr_prefix" {
  description = "Prefix used for naming ACR"
  type        = string
}

variable "acr_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "acr_vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "acr_subnet_name" {
  description = "ACR Registry Subnet"
  type        = string
}
