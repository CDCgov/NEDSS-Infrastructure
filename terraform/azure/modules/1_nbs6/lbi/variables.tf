variable "prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "lbi_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "lbi_vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "lbi_subnet_name" {
  description = "Subnet to deploy Load Balancer in"
  type        = string
}

variable "lbi_aci_ip_list" {
  description = "ACI Subnet IP list"
  type        = list
}

variable "lbi_private_ip" {
  description = "ACI Subnet IP list. Mix/Max 3 Required"
  type        = list
}

