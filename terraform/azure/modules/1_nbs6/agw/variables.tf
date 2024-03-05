variable "prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "agw_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "agw_vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "agw_subnet_name" {
  description = "Subnet to deploy App Gateway in"
  type        = string
}

variable "agw_aci_ip_list" {
  description = "ACI Subnet IP list"
  type        = list
}