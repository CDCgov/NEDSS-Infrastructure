terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # Precreate s3 bucket named "cdc-nbs-sandbox-terraform"
  backend "s3" {
    encrypt = true
    #change following 2 lines and comment this one
    bucket  = "cdc-nbs-test-terraform"
    key = "cdc-nbs-test/infrastructure-artifacts"
    region = "us-east-1"
  }
}

