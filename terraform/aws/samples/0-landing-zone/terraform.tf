terraform {
  # Reference info: https://developer.hashicorp.com/terraform/language/block/terraform#required_version
  required_version = ">= 1.15.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.21.0, < 7.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.1, < 4.0.0"
    }
  }

  # Precreate s3 bucket following your IT naming convention
  # Replace the variables by searching for "EXAMPLE"
  backend "s3" {
    encrypt = true
    bucket  = "<EXAMPLE_AWS_S3_BUCKET_NAME>"                           # e.g. cdc-nbs-tfstate
    key     = "<EXAMPLE_ENVIRONMENT>/0-landing-zone/terraform.tfstate" # e.g. nbs7-env/production/0-landing-zone.tfstate
    region  = "<EXAMPLE_AWS_REGION>"                                   # e.g. us-east-1
  }
}
