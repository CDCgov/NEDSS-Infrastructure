# Terraform Variable initialization-------------------------------
#  Description:
#   The variables defined in this file are required to be input 
#   into the provided modules. If there is NO default value,
#   please provide a value in terraform.tfvars.
#
#-----------------------------------------------------------------

# Non-module specific variables-----------------------------------
variable "resource_prefix" {
  description = "Prefix for resource names"
  type = string
}

variable "aws_eks_cluster_name" {
  description = "Name of EKS cluster. Usually naming follows convention 'var.resource_prefix-eks'. Leave as null to interpret from resource_prefix variables"
  type = string
  default = null
}

