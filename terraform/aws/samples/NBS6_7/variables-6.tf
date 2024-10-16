# Serial: 2024101504

#########################################################################################
# Legacy VPC Variables
#########################################################################################
#variable "legacy-name" {
#  description = "A default name for all classic resources, may use resource_prefix instead of this"
#  type        = string
#  default     = "cdc-nbs-legacy-vpc"
#}

# this may be unused with latest deployment file updates
variable "classic_resource_prefix" {
  type        = string
  description = "Prefix for classic resource names"
  #default     = "cdc-nbs-legacy"
  default = "cdc-nbs-classic"
}

variable "legacy-cidr" {
  description = "CIDR for classic VPC"
  type        = string
}

variable "legacy-azs" {
  description = "A list of AZs for classic resources"
  type        = list(any)
}

variable "legacy-private_subnets" {
  description = "A list of private subnets for classic resources"
  type        = list(any)
}

variable "legacy-public_subnets" {
  description = "A list of public subnets for classic resources"
  type        = list(any)
}

variable "legacy-create_igw" {
  description = "Create an internet gateway for the classic VPC (true/false)"
  type        = bool
  default     = true
}

variable "legacy-enable_nat_gateway" {
  description = "enable nat gateway for legacy VPC?  (true/false)"
  type        = bool
  default     = true
}

# can this be combined with next variable?
variable "legacy-single_nat_gateway" {
  description = "enable single nat gateway for all AZs on legacy VPC?  (true/false)"
  type        = bool
  default     = true
}

variable "legacy-one_nat_gateway_per_az" {
  description = "enable one nat gateway per az on legacy VPC?  (true/false)"
  type        = bool
  default     = false
}

variable "legacy-enable_dns_hostnames" {
  description = "Enable legacy dns hostnames? (true/false) "
  type        = bool
  default     = true
}

variable "legacy-enable_dns_support" {
  description = "Enable legacy dns support? (true/false) "
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are `application` or `network`. The default value is `application`"
  type        = string
  default     = "application"
}

variable "load_balancer_internal" {
  description = "If true, the LB will be internal. Defaults to `true`"
  type        = bool
  default     = true
}

# Database settings
variable "db_instance_type" {
  description = "Databae instance type"
  type        = string
}
variable "db_snapshot_identifier" {
  description = "Database snapshot to use for RDS instance"
  type        = string
}
variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = false
}
# end Database settings

# classic on EC2 settings
variable "ec2_key_name" {
  description = "Precreated EC2 key name to manage classic instance"
  type        = string
}
variable "ami" {
  description = "AMI for EC2 instance"
  type        = string
}
variable "ec2_instance_type" {
  description = "Instance type for EC2 instance"
  type        = string
  default     = "m5.large"
}
variable "deployment_package_key" {
  description = "Deployment package S3 key for NBS application"
  type        = string
}
# we can disable user data if needed
# WIP
variable "ec2_enable_user_data" {
  type    = bool
  default = true
}
# end classic on EC2 settings

# NBS container on ECS

variable "shared_services_accountid" {
  description = "Shared Services Account ID. Needed to pull from ECR"
  type        = string
  default     = ""
}

variable "deploy_on_ecs" {
  description = "Deploy Classic NBS on ECS?"
  type        = bool
  default     = false
}

variable "deploy_alb_dns_record" {
  description = "Deploy alb dns record"
  type        = bool
  default     = true
}

variable "docker_image" {
  description = "Docker Image for Classic NBS"
  type        = string
  default     = ""
}

variable "nbs_github_release_tag" {
  description = "Create URL and download Release Package. Default is always latest or Null"
  type        = string
  default     = "latest"
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
# end NBS container on ECS

# End Legacy variables
#########################################################################################

