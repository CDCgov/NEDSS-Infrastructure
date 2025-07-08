variable "subnet_ids" {
  description = "Subnet Id to be used when creating EC2 instance"
  type        = list(any)
  default = []
}

variable "domain_name" {
  description = "Domain name for hosted zone (ex. dev-app.my-domain.com). Required if create_cert == true"
  type        = string
  default = ""
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
  description = "Instance type for EC2 instance. Required if deploy_on_ecs == false."
  type        = string
  default = ""
}

variable "deploy_on_ecs" {
  description = "Deploy Classic NBS on ECS?"
  type        = bool
  default     = false
}

variable "local_bucket" {
  description = "Bucket exists in same account where infrastructure is being deployed"
  type = bool
  default = false
}

variable "deploy_alb_dns_record" {
  description = "Deploy alb dns record"
  type        = bool
  default     = true
}

variable "ecs_subnets" {
  description = "Classic NBS ECS Subnets Configuration"
  type        = list(any)
  default = []
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
  description = "AMI for EC2 instance. (Defaul) Null will use latest Windows 2022 Core Base ami. Required if deploy_on_ecs == false."
  type        = string
  default = null
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

variable "nbs6_ingress_vpc_cidr_blocks" {
  description = "List of CIDR blocks which will have access to nbs6 instance"
  type        = list(any)
  default = []
}

variable "nbs6_rdp_cidr_block" {
  description = "CIDR block in for RDP access"
  type        = list(any)
  default = []
}

variable "resource_prefix" {
  description = "Legacy resource prefix for resources created by this module"
  type        = string
}

# variable "db_instance_type" {
#   description = "Databae instance type"
#   type        = string
# }

# variable "db_snapshot_identifier" {
#   description = "Database snapshot to use for RDS isntance"
#   type        = string
# }

variable "ec2_key_name" {
  description = "EC2 key pair to manage instance. Required if deploy_on_ecs == false."
  type        = string
  default = ""
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

variable "update_route53_a_record" {
  description = "Updates route53 A record"
  type        = bool
  default     = false
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
  description = "S3 bucket name used to store build artifacts. Required if deploy_on_ecs == false."
  type        = string
  default = ""

}

variable "deployment_package_key" {
  description = "Deployment package S3 key for NBS application. Required if deploy_on_ecs == false."
  type        = string
  default = ""

}

variable "nbs_db_dns" {
  description = "NBS database server dns"
  type        = string

}

variable "nbs_github_release_tag" {
  description = "Create URL and download Release Package. Default is always latest or Null"
  type        = string
}

variable "kms_arn_shared_services_bucket" {
  description = "KMS key arn used to encrypt shared services s3 bucket"
  type        = string
  default = ""
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

variable "param_store_key_id" {
  description = "(optional) KMS key id used to encrypt parameter store SecureString to be read by EC2 instance"
  type        = string
  default = null
}

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

variable "phcrimporter_user" {
  description = "User needed to run phcrimporter batch job (leave_default=preserve Wildfly default)"
  type        = string
  default = "leave_default"
  sensitive = true
}

# Variable which creates a Windows Scheduled Task for BatchFiles
# Batch include .bat scripts located in the nbs6 subdirectory "BatchFiles" or anything within that subdirectory
# Each Windows Scheduled Task must follow the format -- filename, scriptPathFromWorkDir, dailyStartTime, dailyStopTime, frequencyDays, frequencyHours, frequencyMinutes;
# Where:
# filename = exact name of Batch File (.bat) to be run
# scriptPathFromWorkDir = subdirectory from BatchFiles directory containing your Batch File (typically retired\ or left empty)
# dailyStartTime = standard time to start scheduled Windows Scheduled Task each (e.g. 8:00:00am)
# dailyStopTime = standard time to stop scheduled Windows Scheduled Task each day (e.g. 8:00:00pm)
# frequencyDays = frequency in days to repeat Windows Scheduled Task
# frequencyHours = frequency in hours to repeat Windows Scheduled Task
# frequencyMinutes = frequency in minutes to repeat Windows Scheduled Task
variable "windows_scheduled_tasks" {
  description = "Scheduled tasks in semicolon-separated list providing, note the trailing ';' - filename,scriptPathFromWorkDir,startTime,frequencyDays,frequencyHours,frequencyMinutes;"
  type = string
  default = "ELRImporter.bat,, 6:00:00am, 6:00:00pm, 0, 0, 2; MsgOutProcessor.bat,, 6:00:00am, 7:00:00pm, 0, 0 , 2; UserProfileUpdateProcess.bat, retired\\, 12:00:00am,, 1, 0, 0; DeDuplicationSimilarBatchProcess.bat, retired\\, 7:00:00pm,, 1, 0 , 0; covid19ETL.bat,, 5:00:00am,, 1, 0 , 0; PHCRImporter.bat,, 6:00:00am, 7:00:00pm, 0, 1 , 0;"
}

variable "java_memory" {
  description = "Memory for Wildfly server to run Java (NOTE should not exceed 70% of VM memory)"
  type = string
  default = "4g"
}

variable "max_meta_space_size" {
  description = "Max non-heap memory area used to store metadata such as class definitions, method data, and field data."
  type = string
  default = "512M"
}
