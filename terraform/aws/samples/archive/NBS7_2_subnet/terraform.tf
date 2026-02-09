terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # Precreate s3 bucket named "cdc-nbs-sandbox-terraform"
  backend "s3" {
    encrypt = true
    #change following 2 lines and uncomment them
    # bucket  = "sample-bucket"
    # key = "sample_path/infrastructure-artifacts"
    region = "us-east-1"
  }
}

