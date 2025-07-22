# Serial: 2024101503

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

# SAS on EC2 settings
#### SAS9 vars
variable "sas_ami" {
  description = "sas9 rhel ami from shared services account"
  type        = string
  # default = "ami-09260f644dc4ea3fd"   # from FTS1 for now, FIXME
  default = "ami-07a25505d7a157e9d" # from shared-services
}

variable "sas_keypair_name" {
    description = "sas key pair"
}

variable "sas_instance_type" {
    description = "sas9 instance type"
    default = "t3.large"
}

variable "sas_kms_key_id" {
    description = "kms key arn to be used to encrypt root volume"
}

variable "sas_root_volume_size" {
    description = "root volume size for sas server"
    default = "200"
}

# variable "sas_subnet_id" {
#     description = "private subnet for sas server"
# }

# end SAS on EC2 settings

# RDS (considered existing in DB)
# Database credentials to be encrypted and stored as SecureStrings in parameter store
variable "odse_user" {
  description = "User for odse database"
  type        = string
  sensitive = true
}

variable "odse_pass" {
  description = "Password for odse database"
  type        = string
  sensitive = true
}

variable "rdb_user" {
  description = "User for odse database"
  type        = string
  sensitive = true
}

variable "rdb_pass" {
  description = "Password for odse database"
  type        = string
  sensitive = true
}

variable "srte_user" {
  description = "User for odse database"
  type        = string
  sensitive = true
}

variable "srte_pass" {
  description = "Password for odse database"
  type        = string
  sensitive = true
}

variable "windows_scheduled_tasks" {
  description = "Scheduled tasks in semicolon-separated list providing, note the trailing ';' - filename,scriptPathFromWorkDir,startTime,frequencyDays,frequencyHours,frequencyMinutes;"
  type = string
  default = "ELRImporter.bat,, 6am, 0, 0, 1; MsgOutProcessor.bat,, 6am, 0, 0 , 1; UserProfileUpdateProcess.bat, retired\\, 12am, 1, 0, 0; DeDuplicationSimilarBatchProcess.bat, retired\\, 7pm, 1, 0 , 0; covid19ETL.bat,, 5am, 1, 0 , 0; PHCRImporter.bat,, 6am, 0, 1 , 0;"
}

variable "java_memory" {
  description = "Memory for Wildfly server to run Java (NOTE should not exceed 70% of VM memory)"
  type = string
  default = "4g" ### this should be 4g for m5.large
}
variable "phcrimporter_user" {
  description = "User needed to run phcrimporter batch job (leave_default=preserve Wildfly default)"
  type        = string
  default = "nedss_elr_load"
  sensitive = true
}
