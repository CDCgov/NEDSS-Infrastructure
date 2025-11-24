variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "nbs"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"

}

variable "cluster_name" {
  type        = string
  description = "Name of AKS cluster for which monitoring will be set up"

}

variable "update_admin_role_assignment" {
  type        = bool
  description = "Allow observability to give deployment role admin permissions to the grafana dashboard"
  default     = true
}