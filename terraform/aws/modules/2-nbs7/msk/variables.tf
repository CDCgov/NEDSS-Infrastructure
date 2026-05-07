variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "create_msk" {
  type        = bool
  description = "Create MSK cluser and required resources?"
  default     = true
}

variable "environment" {
  type        = string
  description = "The environment - either 'development' or 'production', which means by default two brokers of size kafka.t3.small or three kafka.m5.large brokers, respectively."
  default     = "development"
  validation { # Note that `terraform validate` can only perform some checks, but all validation rules will be evaluated by `terraform plan`.
    condition     = contains(["development", "production"], var.environment)
    error_message = "This variable must be development or production."
  }
}

variable "msk_subnet_ids" {
  description = "The list of subnets to use, which determines how many AZs (Availability Zones) the cluster uses. There must be 2+ subnets for a 'development' environment, otherwise 3+ subnets."
  type        = list(string)
  validation {
    # AWS requires at least one broker per AZ. Thus checking the number of subnets here ensures the implementation of this module will create enough brokers.
    # Note that there is no advantage to providing more than the minimum required number of subnets, because this module only creates 2 or 3 brokers (plus additional_brokers_to_create).
    # Heads up that if at some point after creating a cluster you add a subnet to it, that will require the cluster to be re-created - which causes the topics and other data in the cluster to be deleted.
    condition     = ((var.environment == "development" && length(var.msk_subnet_ids) >= 2)) || (length(var.msk_subnet_ids) >= 3)
    error_message = "There must be 2+ subnets for a 'development' environment, otherwise 3+ subnets."
  }
}

variable "additional_brokers_to_create" {
  type = number
  # The MSK requirement mentioned below is documented at https://docs.aws.amazon.com/msk/latest/developerguide/msk-update-broker-count.html
  description = "How many additional brokers to create - beyond the default of two for 'development' or otherwise three. AWS MSK requires that the number of brokers must be a multiple of the number of Availability Zones."
  default     = 0
  validation {
    condition     = ((var.environment == "development") && ((2 + var.additional_brokers_to_create) % length(var.msk_subnet_ids) == 0)) || ((var.environment == "production") && ((3 + var.additional_brokers_to_create) % length(var.msk_subnet_ids) == 0))
    error_message = "Invalid combo of number of subnets and brokers specified. AWS MSK requires that the number of brokers must be a multiple of the number of Availability Zones."
  }
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
