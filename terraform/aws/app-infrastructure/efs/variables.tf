variable "name" {
  description = "Name to be used for EFS (an overwrite option to use a custom name)"
  type        = string
  default = ""
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "vpc_id" {
  description = "VPC ID for EFS"
  type        = string
  validation {
    condition = (
    can(regex("^[a-zA-Z0-9]([a-zA-Z0-9]*-[a-zA-Z0-9])*[a-zA-Z0-9]+$", var.vpc_id)) &&
    length(var.vpc_id) <= 128
    )
    error_message = "Invalid vpc_id. The name must have 1-128 characters. Valid characters: a-z, A-Z, 0-9 and -(hyphen). The name can’t start or end with a hyphen, and it can’t contain two consecutive hyphens."
  }
}

variable "vpc_cidrs" {
  description = "list of VPC CIDRs"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "mount_targets" {
  description = "Mount targets to be used for EFS"
  type        = any
  default     = {}
}

variable "kms_key_arn" {
  description = "AWS KMS key resource name to be used for EFS encryption"
  type        = string
}
