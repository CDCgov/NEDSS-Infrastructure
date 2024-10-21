variable "resource_prefix" {
  description = "Prefix used for naming all resources"
  type        = string
}

variable "aci_resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "aci_vnet_name" {
  description = "Name of vNet"
  type        = string
}

variable "aci_subnet_name" {
  description = "Subnet to deploy ACI in. ACI Subnet should be the smallest CIDR Block"
  type        = string
}

variable "aci_cpu" {
  description = "CPU Allocation for NBS6 ACI"
  type        = string
}

variable "aci_memory" {
  description = "CPU Allocation for NBS6 ACI"
  type        = string
}

variable "aci_github_release_tag" {
  description = "Create URL and download Release Package from Release Artifacts. Default is always latest even if empty"
  type        = string
  default      = "latest"
}

variable "aci_quay_nbs6_repository" {
  description = "Quay.io NBS6 Repository"
  type        = string
}

# SAS specific variables 
# variable "deploy_sas" {
#   description = "(true/false) Deploy SAS task? Will create ECS cluster if not existing?"
#   type = bool
#   default = false  
# }

variable "aci_sas_repository" {
  description = "Repository plus image tag for SAS container"
  type        = string
  default = ""
}

variable "aci_sas_cpu" {
  description = "Classic NBS ECS CPU Configuration"
  type        = string
  default     = "2048"
}

variable "aci_sas_memory" {
  description = "Classic NBS ECS Memory Configuration"
  type        = string
  default     = "8192"
}

variable "sas_ephemeral_storage" {
  description = "Ephemeral storage in GB for SAS"
  type        = string
  default = "100"
}

variable "db_trace_on" {
  description = "(Yes/No) Turn on trace to stdout for database connection debugging."
  type        = string
  default     = "No"
}

variable "update_database" {
  description = "(true/false) Enable SAS container to update Database with its IP address?"
  type        = string
  default     = "false"
}

variable "phcmartetl_cron_schedule" {
  description = "Cron schedule for PHCMart ETL process"
  type        = string
  default     = "0 0 * * *"
}

variable "masteretl_cron_schedule" {
  description = "Cron schedule for Master ETL process"
  type        = string
  default     = "0 0 * * *"
}

variable "rdb_user" {
  description = "NBS user for RDB database"
  type        = string
  default = ""
}

variable "rdb_pass" {
  description = "NBS password for RDB database"
  type        = string
  default = ""
  sensitive = true
}

variable "odse_user" {
  description = "NBS user for ODSE database"
  type        = string
  default = ""
}

variable "odse_pass" {
  description = "NBS password for ODSE database"
  type        = string
  default = ""
  sensitive = true
}