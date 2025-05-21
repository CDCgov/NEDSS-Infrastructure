variable "sftp_bucket_name" {
  description = "The name of the S3 bucket used by AWS Transfer Family"
  type        = string
}


variable "alert_email_address" {
  description = "Email address to subscribe to Lambda error notifications"
  type        = string
}
