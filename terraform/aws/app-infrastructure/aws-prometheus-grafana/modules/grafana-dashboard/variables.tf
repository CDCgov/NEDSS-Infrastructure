#Define AWS Region
# variable "region" {
#   description = "Infrastructure region"
#   type        = string
#   default     = "us-east-1"
# }
variable "amg_api_token" {
  type = string
}
variable "grafana_workspace_url" {
  type = string
}

variable "amp_url" {
  type = string
}

variable "data_source_uid" {
  type    = string
  default = "prom_ds_uid"
}
