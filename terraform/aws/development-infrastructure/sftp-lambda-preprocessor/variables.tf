variable "sftp_bucket_name" {
  description = "The name of the S3 bucket used by AWS Transfer Family"
  type        = string
}


variable "alert_email_address" {
  description = "Email address to subscribe to Lambda error notifications"
  type        = string
}

variable "filter_prefix" {
  description = "S3 key prefix to trigger the Lambda function"
  type        = string
  default     = "site/lab/incoming/" # Change as needed
}

