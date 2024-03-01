variable "prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "appgw_subnet_name" {
  description = "Subnet to deploy App Gateway in"
  type        = string
}

variable "aci_subnet_name" {
  description = "Subnet to deploy ACI in. ACI Subnet should be the smallest CIDR Block"
  type        = string
}

variable "aci_ip_list" {
  description = "ACI Subnet IP list"
  type        = list
}

variable "quay_nbs6_repository" {
  description = "Quay.io NBS6 Repository"
  type        = string
}

variable "sql_database_endpoint" {
  description = "SQL Database endpoint"
  type        = string
}