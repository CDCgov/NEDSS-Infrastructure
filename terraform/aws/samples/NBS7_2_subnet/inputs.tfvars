# Account variables
# updated github global secrets to remove single quoting
#
#
# Search and replace SITE_NAME and EXAMPLE_DOMAIN
# OCTET2a, OCTET2b, OCTET2shared
# search for all other EXAMPLE
#

# Non-module specific variables
target_account_id = "090466851254"
resource_prefix   = "cdc-nbs-test" # highly recommend using snake case for naming (e.g. this-is-snake-case)

# Modernization Infrastructure
# VPC Variables
# modern-cidr            = "10.OCTET2a.0.0/16"
# modern-azs             = ["us-east-1a", "us-east-1b"]
# modern-private_subnets = ["10.OCTET2a.1.0/24", "10.OCTET2a.3.0/24"]
# modern-public_subnets  = ["10.OCTET2a.2.0/24", "10.OCTET2a.4.0/24"]

# Legacy Infrastructure (grab all of these from existing environment)
# VPC Variables
# legacy-cidr                       = "10.OCTET2b.0.0/16"
# legacy-vpc-id                     = "vpc-LEGACY-EXAMPLE"
# legacy_vpc_private_route_table_id = "rtb-PRIVATE-EXAMPLE"
# legacy_vpc_public_route_table_id  = "rtb-PUBLIC-EXAMPLE"

# Tags
tags = {
  "Project"     = "NBS"
  "Environment" = "TEST"
  "Owner"       = "CDC"
  "Terraform"   = "true"
}

# EKS cluster Variables
eks_instance_type = "m5.large"
# grab from login screen
aws_admin_role_name = ""
sso_admin_role_name = ""
use_ecr_pull_through_cache = true
external_cidr_blocks = []

# S3 buckets
fluentbit_bucket_prefix = "cdc-nbs-test-fluentbit-bucket"

# Helm deployment


