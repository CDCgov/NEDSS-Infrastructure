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
