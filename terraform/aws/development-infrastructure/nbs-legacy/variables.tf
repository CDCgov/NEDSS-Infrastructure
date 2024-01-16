variable "private_subnet_ids" {
  description = "Subnet Id to be used when creating EC2 instance"
  type        = list(any)
}

variable "domain_name" {
  description = "Domain name for hosted zone (ex. dev-app.my-domain.com)"
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnet Id to be used when creating ALB"
  type        = list(any)
}

variable "instance_type" {
  description = "Instance type for EC2 instance"
  type        = string
}

variable "deploy_on_ecs" {
  description = "Deploy Classic NBS on ECS?"
  type        = bool
  default     = false
}

variable "docker_image" {
  description = "Docker Image for Classic NBS"
  type        = string
}

variable "ami" {
  description = "AMI for EC2 instance"
  type        = string
}

variable "legacy_vpc_id" {
  description = "VPC ID of virtual private cloud"
  type        = string
}

variable "modern_vpc_id" {
  description = "VPC ID of virtual private cloud"
  type        = string
}

variable "shared_vpc_cidr_block" {
  description = "VPC CIDR block in shared services account"
  type        = string
}

variable "legacy_resource_prefix" {
  description = "Legacy resource prefix for resources created by this module"
  type        = string
}

variable "db_instance_type" {
  description = "Databae instance type"
  type        = string
}

variable "db_snapshot_identifier" {
  description = "Database snapshot to use for RDS isntance"
  type        = string
}

variable "ec2_key_name" {
  description = "EC2 key pair to manage instance"
  type        = string
}

variable "tags" {
  description = "map(string) of tags to add to created resources"
  type        = map(string)
}

variable "route53_url_name" {
  description = "URL name for Classic App as an A record in route53 (ex. app-dev.my-domain.com)"
  type        = string
}

variable "zone_id" {
  description = "Route53 Hosted Zone Id"
  type        = string
}

variable "create_cert" {
  description = "Do you want to create a public AWS Certificate (if false (default), must provide certificate ARN)."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "If create_cert == false, provide a certificate_arn"
  type        = string
  default     = ""
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name used to store build artifacts"
  type        = string

}

variable "deployment_package_key" {
  description = "Deployment package S3 key for NBS application"
  type        = string

}

variable "nbs_db_dns" {
  description = "NBS database server dns"
  type        = string

}

variable "kms_arn_shared_services_bucket" {
  description = "KMS key arn used to encrypt shared services s3 bucket"
  type        = string
}

variable "apply_immediately" {
  type = bool
  default = false
}