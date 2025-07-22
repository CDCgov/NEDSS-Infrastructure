# Account variables
# updated github global secrets to remove single quoting
#
#
# Search and replace SITE_NAME and EXAMPLE_DOMAIN
# OCTET2a, OCTET2b, OCTET2shared
# search for all other EXAMPLE
#

# Non-module specific variables
target_account_id = "EXAMPLE_ACCOUNT_ID"
resource_prefix   = "EXAMPLE_RESOURCE_PREFIX" # highly recommend using snake case for naming (e.g. this-is-snake-case)

# Modernization Infrastructure
# VPC Variables
modern-cidr            = "10.OCTET2a.0.0/16"
modern-azs             = ["us-east-1a", "us-east-1b"]
modern-private_subnets = ["10.OCTET2a.1.0/24", "10.OCTET2a.3.0/24"]
modern-public_subnets  = ["10.OCTET2a.2.0/24", "10.OCTET2a.4.0/24"]

# Legacy Infrastructure (grab all of these from existing environment)
# VPC Variables
legacy-cidr                       = "10.OCTET2b.0.0/16"
legacy-vpc-id                     = "vpc-LEGACY-EXAMPLE"
legacy_vpc_private_route_table_id = "rtb-PRIVATE-EXAMPLE"
legacy_vpc_public_route_table_id  = "rtb-PUBLIC-EXAMPLE"

# Tags
tags = {
  "Project"     = "NBS"
  "Environment" = "EXAMPLE_ENVIRONMENT"
  "Owner"       = "CDC"
  "Terraform"   = "true"
}

# EKS cluster Variables
eks_instance_type = "m5.large"
# grab from login screen
aws_admin_role_name = "aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE"

# optional role to authenticate into the EKS cluster for ReadOnly, leave empty if not needed
readonly_role_name = "aws-reserved/sso.amazonaws.com/AWSReservedSSO_ReadOnlyAccess_EXAMPLE_ROLE" 


# S3 buckets
fluentbit_bucket_prefix = "EXAMPLE-fluentbit-bucket"
fluentbit_bucket_name = "EXAMPLE-fluentbit-logs"
