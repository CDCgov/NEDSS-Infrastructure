variable "private_subnet_ids" {
  description = "Subnet Id to be used when creating EC2 instance"
  type        = list(any)
}

variable "domain_name" {
  description = "Domain name for hosted zone (ex. dev-app.my-domain.com)"
  type        = string
}

variable "load_balancer_subnet_ids" {
  description = "Subnet Id to be used when creating load balancer. Conflicts with subnet_mapping (which take precedence if set)."
  type        = list(any)
  default = null
}


variable "subnet_mapping" {
  description = "A list of subnet mapping blocks describing subnets to attach to load balancer. Map keys = subnet_id, private_ipv4_address. Conflicts with load_balancer_subnet_ids (subnet_mapping takes precedence)."
  type        = list(map(string))
  default     = []

  # Example
  # [
  #   {
  #     private_ipv4_address_1 = ""
  #     subnet_id_1     = ""
  #   },
  #   {
  #     private_ipv4_address_2 = ""
  #     subnet_id_2     = ""
  #   }
  # ]
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

variable "ecs_subnets" {
  description = "Classic NBS ECS Subnets Configuration"
  type        = list(any)
}

variable "docker_image" {
  description = "Docker Image for Classic NBS"
  type        = string
  default = ""
}

variable "ecs_cpu" {
  description = "Classic NBS ECS CPU Configuration"
  type        = string
  default     = "2048"
}

variable "ecs_memory" {
  description = "Classic NBS ECS Memory Configuration"
  type        = string
  default     = "8192"
}

variable "ami" {
  description = "AMI for EC2 instance"
  type        = string
}

# variable "legacy_vpc_id" {
#   description = "VPC ID of virtual private cloud"
#   type        = string
# }

# variable "modern_vpc_id" {
#   description = "VPC ID of virtual private cloud"
#   type        = string
# }

variable "vpc_id" {
  description = "VPC ID of virtual private cloud"
  type        = string
}

variable "ingress_vpc_cidr_blocks" {
  description = "CSV of CIDR blocks which will have access to RDS instance"
  type        = string
  default = ""
}

variable "rdp_cidr_block" {
  description = "CIDR block in for RDP access"
  type        = string
  default = ""
}

variable "resource_prefix" {
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
  description = "URL name for Classic App as an A record in route53 (ex. app-dev.my-domain.com). Requires zone_id to be set."
  type        = string
  default = ""
}

variable "zone_id" {
  description = "Route53 Hosted Zone Id. Requires route53_url_name to be set."
  type        = string
  default = ""
}

variable "create_cert" {
  description = "Do you want to create a public AWS Certificate (if false (default), must provide certificate_arn). Requires zone_id to be set."
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

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are `application` or `network`. The default value is `network`"
  type        = string
  default     = "network"
}

variable "internal" {
  description = "If true, the LB will be internal. Defaults to `false`"
  type        = bool
  default     = null
}
