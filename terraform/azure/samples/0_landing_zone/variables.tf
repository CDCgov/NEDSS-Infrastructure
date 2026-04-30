
## VNET

variable "vnet_resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "vnet_location" {
  type        = string
  description = "Azure region where the vnet will be placed"
}

variable "vnet_parent_id" {
  type        = string
  description = "Resource group parent id"
}

variable "vnet_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}


## ACR

variable "acr_resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "acr_subnet_name" {
  description = "The subnet name the ACR is associated with"
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
