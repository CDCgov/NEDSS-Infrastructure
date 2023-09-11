

variable "region" {}
variable "WORKSPACE_ID" {}
variable "IAM_PROXY_PROMETHEUS_ROLE_ARN" {}
variable "repository" {}
variable "chart" {}
variable "values_file_path" {}
variable "namespace_name" {}
variable "dependency_update" {type = bool} 
variable "lint" {type = bool}
variable "force_update" {type = bool}
