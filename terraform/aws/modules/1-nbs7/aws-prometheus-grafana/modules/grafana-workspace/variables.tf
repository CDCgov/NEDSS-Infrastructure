variable "data_sources" {
  description = "the datasource for grafana; in this case Prometheus"
  type        = list(any)
  default     = ["PROMETHEUS"]
}

variable "grafana_workspace_name" {
  description = "The name of the Grafana workspace"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to resources"
  type        = map(string)
}

variable "endpoint_url" {
  description = "The URL of the endpoint"
  type        = string
}

variable "amp_workspace_id" {
  description = "The ID of the Amazon Managed Prometheus workspace."
  type        = string
}

variable "region" {
  description = "The AWS region to use for the resources"
  type        = string
}

variable "resource_prefix" {
  description = "The prefix text to add to the start of each resource name"
  type        = string
}