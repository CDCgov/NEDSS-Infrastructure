variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "grafana_workspace_id" {
  description = "The ID of the Grafana workspace"
  type        = string
}

variable "service_account_id" {
  description = "The ID of the Grafana service account"
  type        = string
}

variable "token_expiration_days" {
  description = "Number of days until the token expires"
  type        = number
  default     = 30
}

variable "rotation_schedule_days" {
  description = "Number of days between token rotations (should be less than token_expiration_days)"
  type        = number
  default     = 25
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
}