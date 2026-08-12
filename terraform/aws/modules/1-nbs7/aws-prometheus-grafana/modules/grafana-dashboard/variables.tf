#Define AWS Region
variable "region" {
  description = "The AWS region to use for the resources"
  type        = string
}

variable "amg_api_token" {
  description = "The API token for Amazon Managed Grafana"
  type        = string
}

variable "grafana_workspace_url" {
  description = "The URL of the Grafana workspace"
  type        = string
}

variable "amp_url" {
  description = "The URL of the Amazon Managed Prometheus workspace"
  type        = string
}

variable "data_source_uid" {
  description = "The UID to give the Prometheus data source"
  type        = string
  default     = "prom_ds_uid"
}