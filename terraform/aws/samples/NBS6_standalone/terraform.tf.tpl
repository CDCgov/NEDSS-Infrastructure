# Serial: 2024032001

# new file breaks out providers and backend from main.tf
# but will cause a problem if corresponding lines are not removed from
# main.tf (make sure s3 key matches in preexisting accounts

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.100, < 6.0.0"
    }
 
    helm = {
      source = "hashicorp/helm"
      version = "2.17.0"
    }
  }

  # Precreate(d) s3 bucket named "cdc-nbs-sandbox-terraform"
  backend "s3" {
    encrypt = true
    #change following 2 lines and comment this one
    bucket = "cdc-nbs-terraform-<EXAMPLE_ACCOUNT_NUM>"
    key    = "cdc-nbs-SITE_NAME-modern/infrastructure-artifacts"
    region = "us-east-1"
  }
}

# provider "aws" {
#   assume_role {
#     role_arn     = "arn:aws:iam::${var.target_account_id}:role/cdc-terraform-user-cross-account-role"
#     session_name = "deploy-base-infrastructure"
#   }
#   ignore_tags {
#     keys = ["cdc-nbs:schedule", "InstanceScheduler-LastAction", "cdc-nbs:owner", "cdc-nbs:principal-Id"]
#   }
# }
