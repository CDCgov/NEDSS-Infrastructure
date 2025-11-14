variable "data_sources" {
  type        = list(any)
  description = "the datasource for grafana; in this case Prometheus"
  default     = ["PROMETHEUS"]
}
variable "grafana_workspace_name" {}
variable "tags" {}
variable "endpoint_url" {}
variable "amp_workspace_id" {}
variable "region" {}
variable "resource_prefix" {}
variable "grafana_api_key_expiration_days" {
  description = "Number of days until the Grafana API key expires"
  type = number
  default = 30

validation {
    condition     = var.grafana_api_key_expiration_days >= 30 && var.grafana_api_key_expiration_days <= 365
    error_message = "The Grafana API key expiration days must be between 30 and 365."
  }
}