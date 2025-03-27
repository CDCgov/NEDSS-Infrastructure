variable "bucket_name" {
  description = "Name of the S3 bucket for HL7 uploads"
  type        = string
  default     = "my-transfer-bucket"
}

variable "enable_sftp" {
  description = "Enable AWS Transfer Family server + user setup"
  type        = bool
  default     = true
}

variable "enable_split_and_validate" {
  description = "Enable HL7 validation and OBR-splitting Lambda"
  type        = bool
  default     = true
}

variable "enable_error_notifications" {
  description = "Enable SNS notifications for errors"
  type        = bool
  default     = true
}

variable "enable_success_notifications" {
  description = "Enable SNS notifications for success"
  type        = bool
  default     = true
}

variable "enable_summary_notifications" {
  description = "Enable daily summary notifications"
  type        = bool
  default     = true
}

variable "notification_emails" {
  description = "Map of notification types to lists of emails"
  type = object({
    error   = list(string)
    success = list(string)
    summary = list(string)
  })
  default = {
    error   = ["alerts+errors@example.com"]
    success = ["alerts+success@example.com"]
    summary = ["alerts+summary@example.com"]
  }
}

variable "sites" {
  description = "Map of sites and their publishers"
  type = map(list(string))
  default = {
    siteA = ["publisher1", "publisher2"]
    siteB = ["publisher3"]
  }
}

variable "summary_schedule_expression" {
  description = "EventBridge cron expression for summary notifications"
  type        = string
  default     = "cron(0 0 * * ? *)"
}
