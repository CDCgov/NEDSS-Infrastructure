variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "create_msk" {
  type        = bool
  description = "Create msk cluser and required resources?"
  default     = true
}

variable "environment" {
  type        = string
  description = "The environment, either 'development' or 'production'. This module creates kafka.t3.small brokers for 'development', otherwise kafka.m5.large brokers are created."
  default     = "development"
  validation { # Note that `terraform validate` can only perform some checks, but all validation rules will be evaluated by `terraform plan`.
    condition     = contains(["development", "production"], var.environment)
    error_message = "This variable must be development or production."
  }
}

variable "msk_subnet_ids" {
  description = "The list of subnets to use for the MSK cluster. There must be 2+ subnets for a 'development' environment, otherwise 3+ subnets."
  type        = list(string)
  validation {
    # The number of subnets determines how many AZs (Availability Zones) the cluster uses. AWS requires at least one broker per AZ. Thus checking the number of subnets here ensures the implementation of this module will create enough brokers.
    # Note that there is no advantage to providing more than the minimum required number of subnets, because this module only creates 2 or 3 brokers (plus additional_brokers_to_create).
    # If you add a subnet to an existing MSK cluster that will require the cluster to be re-created which causes the topics/data in the cluster to be deleted.
    condition     = (var.environment == "development" && length(var.msk_subnet_ids) >= 2) || (length(var.msk_subnet_ids) >= 3)
    error_message = "There must be 2+ subnets for a 'development' environment, otherwise 3+ subnets."
  }
}

variable "additional_brokers_to_create" {
  type        = number
  description = "How many additional brokers to create - beyond two for 'development' or otherwise three."
  default     = 0
}

variable "msk_ebs_volume_size" {
  description = "EBS volume size for the MSK broker nodes in GB"
  type        = number
}

variable "vpc_id" {
  description = "VPC Id to be used with cluster"
  type        = string
}

# variable "modern-cidr" {
#   description = "VPC CIDR to be used with cluster SG"
#   type        = string
# }
# variable "vpn-cidr" {
#   description = "VPN VPC CIDR to be used with cluster SG"
#   type        = string
#   default = null
# }

variable "cidr_blocks" {
  type = list(any)
}

variable "kafka_version" {
  description = "Version of Kafka to be deployed in cluster"
  type        = string
  default     = "3.6.0"
}
