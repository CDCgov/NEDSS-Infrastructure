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