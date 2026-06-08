# Assume role in hosted-zone account
provider "aws" {
  alias = "hosted-zone-account"
  assume_role {
    role_arn     = var.hosted-zone-iam-arn
    session_name = "deploy-base-infrastructure"
  }
}