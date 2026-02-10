# 2-nbs7 parameter inputs
#
# Search and replace variable values beginning with "EXAMPLE_" to appropriate values

# Non-module specific variables
resource_prefix = "EXAMPLE_RESOURCE_PREFIX" # highly recommend using snake case for naming (e.g. this-is-snake-case)
vpc_id          = "EXAMPLE_VPC_ID"
domain_name     = "EXAMPLE_DOMAIN_NAME" #e.g. nbspreview.com

# Tags (suggested tags for resources)
tags = {
  "Project"     = "NBS"
  "Environment" = "EXAMPLE_ENVIRONMENT"
  "Owner"       = "EXAMPLE_OWNER"
  "Terraform"   = "true"
}


# Modernization Infrastructure
# EKS Variables
aws_role_arn                     = "EXAMPLE_IAM_ARN"                        # REQUIRED, will be concated in list admin_role_arns if list is also provided
readonly_role_arn                = null                                     # OPTIONAL will be concated in list readonly_role_arns if list is also provided
admin_role_arns                  = []                                       # Use list to provide multiple admin roles
readonly_role_arns               = []                                       # Use list to provide multiple readonly roles
kms_key_administrators           = ["EXAMPLE_IAM_ARN", "EXAMPLE_IAM_ARN_2"] # Used to create KMS key administrators for EKS 
eks_allow_endpoint_public_access = true

# MSK
msk_environment = "production"

