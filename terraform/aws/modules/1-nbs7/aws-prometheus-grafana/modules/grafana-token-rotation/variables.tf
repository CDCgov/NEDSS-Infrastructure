variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "grafana_workspace_id" {
  type        = string
  description = "The ID of the Grafana workspace"
}

variable "service_account_id" {
  type        = string
  description = "The ID of the Grafana service account"
}

variable "token_expiration_days" {
  type        = number
  description = "Number of days until the token expires"
  default     = 30
}

variable "rotation_schedule_days" {
  type        = number
  description = "Number of days between token rotations (should be less than token_expiration_days)"
  default     = 25
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS region"
}