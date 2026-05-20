variable "enabled" {
  description = "Whether to create the resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region (e.g., East US)"
  type        = string
  default     = "East US"
}

