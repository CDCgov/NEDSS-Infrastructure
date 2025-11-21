

variable "region" {}
variable "workspace_id" {}
variable "iam_proxy_prometheus_role_arn" {}
variable "repository" {}
variable "chart" {}
variable "values_file_path" {}
variable "namespace_name" {}
variable "dependency_update" { type = bool }
variable "lint" { type = bool }
variable "force_update" { type = bool }
variable "service_account_amp_ingest_name" {}
