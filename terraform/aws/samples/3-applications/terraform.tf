terraform {
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

  # Precreate s3 bucket following your IT naming convention e.g. "cdc-nbs-terraform"
  # Replace the variables by searching for "EXAMPLE"
  # backend "s3" {
  #   encrypt = true    
  #   bucket = "<EXAMPLE_AWS_S3_BUCKET_NAME>" # e.g. "cdc-nbs-terraform"
  #   key    = "<EXAMPLE_ENVIRONMENT>/3-application/terraform.tfstate" # e.g. production/3-application/terraform.tfstate
  #   region = "<EXAMPLE_AWS_REGION>" # e.g. us-east-1
  # }
}

