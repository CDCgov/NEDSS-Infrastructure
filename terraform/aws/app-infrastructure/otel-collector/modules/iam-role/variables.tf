variable "oidc_provider_arn" {}
variable "oidc_provider" {}
variable "service_account_namespace" {}
variable "service_account_name" {}
variable "resource_prefix" {}
variable "s3_bucket_arn" {}

variable "tags" {
  type = map(string)
}
