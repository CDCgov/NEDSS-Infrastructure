variable "domain_name" {
  description = "Domain name for hosted zone (ex. dev-app.my-domain.com)"
  type        = string
}

variable "sub_domain_name" {
  description = "Sub Domain name for hosted zone used to create NS record in Route53(ex. dev-app)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "map(string) of tags to add to created hosted zone"
  type        = map(string)
}

variable "modern_vpc_id" {
  description = "The ID of the modern VPC. Optional."
  type        = string
  default     = null
}


variable "legacy_vpc_id" {
  description = "Legacy VPC Id"
  type        = string
}

variable "nbs_db_host_name" {
  description = "Host name for RDS database instance"
  type        = string
}

variable "nbs_db_dns" {
  description = "CNAME for NBS DB host"
  type        = string
}

variable "hosted-zone-iam-arn" {
  description = "IAM role ARN to assume for account containing the AWS hosted zone where the domain is registered."
  type        = string
  default     = ""
}

variable "hosted-zone-id" {
  description = "Hosted Zone ID for the AWS hosted zone where the domain is registered. (Blank indicates skipping creation of the NS record)"
  type        = string
  default     = ""
}

