# General Variables
variable "resource_prefix" {
  description = "Prefix applied to all resource names. Recommended to name by environemnt i.e. appname-dev, appname-test"
  type        = string
}

variable "tags" {
  description = "Tags applied to lambda function."
  type        = map(string)
  default     = {}
}

# Lambda Settings
variable "python_runtime" {
  description = "The version of python which runs the code. Note changing this may require a code change."
  type        = string
  default     = "python3.12"
}

variable "tmp_storage" {
  description = "Amount of Lambda ephemeral storage (/tmp) in MB. Valid between 512 MB and 10,240 MB (10 GB)"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Timeout in seconds for lambda function. Default (600s = 10 minutes)"
  type        = number
  default     = 600
}

variable "vpc_id" {
  description = "VPC ID to for security group. Note: used implicitly through subnet references in lambda."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to which lambda is associated. Note: must be associated with vpc_id!"
  type        = list(string)
  # sample
  # ["subnet_id1", "subnet_id2"] 
}

# Lambda trigger
variable "schedule_cron_expression" {
  description = "Cron format trigger schedule for Lambda function"
  type        = string
  default     = "cron(0 0 ? * 1 *)"

  # cron(Minute Hour Day-of-Month Month Day-of-Week Year)
  # This = every Sunday at 00:00 UTC 
}

# lambda async config
variable "maximum_retry_attempts" {
  description = "Number of times to retry Lambda should an error occur."
  type        = number
  default     = 2
}

variable "maximum_event_age_in_seconds" {
  description = "Max Amount of time in seconds spent in queue for async invocation. Default = 3600 sec (1 hour)"
  type        = number
  default     = 3600
}

# Database access
variable "rds_server_name" {
  description = "RDS Server name."
  type        = string
}

variable "database_user_name" {
  description = "Database username with access to messaging database."
  type        = string
  sensitive   = true
}

variable "database_user_password" {
  description = "Database password with access to messaging database."
  type        = string
  sensitive   = true
}

# External SFTP access
# Stored in secrets manager
variable "sftp_hostname" {
  description = "Endpoint for sftp server."
  type        = string
  sensitive   = true
}

variable "sftp_username" {
  description = "SFTP username."
  type        = string
  sensitive   = true
}

variable "sftp_password" {
  description = "SFTP password."
  type        = string
  sensitive   = true
}

# AWS KMS to use, empty equals use default account key
variable "kms_key_id" {
  description = "KMS Key Id to encrypt values. Defaults to AWS managed key for Secrets Manager if not set. Must allow lambda function to decrypt."
  type        = string
  default     = ""
}

# Lambda Environment variables
variable "lambda_env_dry_run" {
  description = "DRY_RUN lambda environment variable. Accepted values = True/False"
  type        = string
  default     = "False"
}

variable "lambda_env_max_batch_size" {
  description = "MAX_BATCH_SIZE lambda environment variable. Accepted values = integer numbers"
  type        = string
  default     = "50"
}

variable "lambda_env_reported_service_types" {
  description = "REPORTED_SERVICE_TYPES lambda environment variable. Accepted values = comma separate entries encapsulated by parenthesis, see default"
  type        = string
  default     = "('NNDM_1.1.3', 'NND_Case_Note', 'NBS_1.1.3_LDF', 'MVPS')"
}

variable "lambda_env_sftp_put_filepath" {
  description = "SFTP_PUT_FILEPATH lambda environment variable. Accepted values = filepath without terminating '/'"
  type        = string
}

variable "lambda_env_log_level" {
  description = "LOG_LEVEL lambda environment variable. Accepted values = INFO, ERROR, DEBUG, WARN"
  type        = string
  default     = "INFO"
} 