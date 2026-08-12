variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "nbs"
}

variable "resource_group_name" {
  description = "Resource group name for existing and to be deployed azure resources"
  type        = string

}

variable "cluster_name" {
  description = "Name of AKS cluster for which monitoring will be set up"
  type        = string
}

variable "location" {
  description = "Location for Azure resources"
  type        = string
}

variable "update_admin_role_assignment" {
  description = "Allow observability to give deployment role admin permissions to the grafana dashboard"
  type        = bool
  default     = true
}

variable "grafana_major_version" {
  description = "Major version number for Grafana"
  type        = string
  default     = "12"
}