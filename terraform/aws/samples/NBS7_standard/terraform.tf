terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.100, < 6.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }

  # Precreate s3 bucket named "cdc-nbs-sandbox-terraform"
  backend "s3" {
    encrypt = true
    #change following 2 lines and comment this one
    bucket = "cdc-nbs-terraform-<EXAMPLE_ACCOUNT_NUM>"
    key    = "cdc-nbs-SITE_NAME-modern/infrastructure-artifacts"
    region = "us-east-1"
  }
}

