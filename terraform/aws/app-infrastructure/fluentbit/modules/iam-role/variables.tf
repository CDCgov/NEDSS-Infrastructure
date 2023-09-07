variable "OIDC_PROVIDER_ARN" {}
variable "OIDC_PROVIDER" {}
variable "SERVICE_ACCOUNT_NAMESPACE" {}
variable "SERVICE_ACCOUNT_NAME" {}

variable "tags" {
  type = map(string)
}
