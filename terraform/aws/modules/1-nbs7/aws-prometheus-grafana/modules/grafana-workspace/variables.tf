variable "data_sources" {
  type        = list(any)
  description = "The data source for Grafana. Only Prometheus is supported."
  default     = ["PROMETHEUS"]
}
variable "grafana_workspace_name" {}
variable "tags" {}
variable "endpoint_url" {}
variable "amp_workspace_id" {}
variable "region" {}
variable "resource_prefix" {}