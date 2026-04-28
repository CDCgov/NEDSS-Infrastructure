variable "parent_id" {
  description = "The name of the existing resource group"
  type        = string
}

variable "vnet_location" {
  description = "The Azure region (e.g., East US)"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the vnet"
  type        = string
  default     = "nbs"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
