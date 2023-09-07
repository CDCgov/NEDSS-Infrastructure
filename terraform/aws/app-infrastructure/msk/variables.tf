#variable "aws_role_arn" {
#  description = "AWS Role arn used to authenticate into EKS cluster"
#  type        = string
#}

variable "environment" {
  description = "The environment, either 'development' or 'production'"
  default     = "development"
}

variable "msk_subnet_ids" {
  description = "A list of subnets to use for the MSK cluster"
  type        = list(string)
}

#variable "msk_security_groups" {
#  description = "A list of security groups to use for the MSK cluster"
#  type        = list(string)
#}

variable "msk_ebs_volume_size" {
  description = "EBS volume size for the MSK broker nodes in GB"
  type        = number
}

variable "vpc_id" {
  description = "VPC Id to be used with cluster"
  type        = string
}

variable "modern-cidr" {
  description = "VPC CIDR to be used with cluster SG"
  type        = string
}
variable "vpn-cidr" {
  description = "VPN VPC CIDR to be used with cluster SG"
  type        = string
}
