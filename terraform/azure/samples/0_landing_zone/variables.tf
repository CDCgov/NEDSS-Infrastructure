variable "resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

## VNET

variable "vnet_location" {
  type        = string
  description = "Azure region where the vnet will be placed"
}

variable "parent_id" {
  type        = string
  description = "Resource group parent id"
}


## ACR

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
