
variable "synthetics_canary_bucket_name" {
  description = "bucket name for synthetics output"
  type        = string
}
variable "synthetics_canary_url" {
  description = "A URL to use for monitoring alerts"
  type        = string
}
# this is defined outside the pipeline (at cli?)
variable "synthetics_canary_create" {
  type        = bool
  description = "Create canary required resources?"
  default     = false
}
#variable "synthetics_canary_email_addresses" {
#  description = "A list of email addresses to use for monitoring alerts"
#  type        = list(string)
#}

