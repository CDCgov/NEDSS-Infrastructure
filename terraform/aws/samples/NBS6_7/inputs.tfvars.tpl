# Serial: 2024101603

# Account variables
# updated github global secrets to remove single quoting
#
#
# Search and replace SITE_NAME and EXAMPLE_DOMAIN
# OCTET2a, OCTET2b, OCTET2shared
# search for all other EXAMPLE
#

################################################################
# Common
################################################################


# Non-module specific variables
target_account_id = "EXAMPLE_ACCOUNT_ID"
resource_prefix   = "EXAMPLE_RESOURCE_PREFIX" # highly recommend using snake case for naming (e.g. this-is-snake-case)
kms_arn_shared_services_bucket = "arn:aws:kms:us-east-1:EXAMPLE_SHARED_SERVICES_ACCOUNT:key/123456-789"

# May generate error when Route53 zone is hosted in another AWS account
hosted-zone-id = "EXAMPLE_HOSTED_ZONE_ID" 
zone_id = ""

# only use this if you are hosting DNS within this account OR have cross
# account access to the account which is authoritative for domain
#hosted-zone-account = "EXAMPLE_ACCOUNT_ID"

domain_name = "EXAMPLE_SITE_NAME.nbspreview.com"
sub_domain_name = "EXAMPLE_SITE_NAME"

# these cidr blocks will be added to security groups to allow direct access
external_cidr_blocks = []


################################################################
# NBS 6 (Classic) 
################################################################

# Legacy Infrastructure 

# VPC Variables
# fill these in if integrating with a pre-existing NBS6 install
# (grab all of these from existing environment)
# legacy-name                   = "cdc-nbs-legacy-vpc"
# legacy-vpc-id                     = "vpc-LEGACY-EXAMPLE"
# legacy_vpc_private_route_table_id = "rtb-PRIVATE-EXAMPLE"
# legacy_vpc_public_route_table_id  = "rtb-PUBLIC-EXAMPLE"

# if building NBS6 select these instead
legacy-cidr                       = "10.OCTET2b.0.0/16"
legacy-azs                    = ["us-east-1a", "us-east-1b"]
legacy-private_subnets        = ["10.OCTET2b.1.0/24", "10.OCTET2b.3.0/24"]
legacy-public_subnets         = ["10.OCTET2b.2.0/24", "10.OCTET2b.4.0/24"]

# in production this should be true
# it will allow access to "classic" interface directly
load_balancer_internal        = false

# Tags
tags = {
  "Project"     = "NBS"
  "Environment" = "EXAMPLE_ENVIRONMENT"
  "Owner"       = "CDC"
  "Terraform"   = "true"
}

########################
# Classic RDS
# Database snapshot to use for RDS instance, must match application version
# db_snapshot_identifier = "cdc-nbs-6-0-16-test"

########################
# Classic on container
# deploy_on_ecs          = true

########################
# Classic EC2 instance


ec2_key_name           = "cdc-nbs-ec2-EXAMPLE_SITE_NAME"

# This needs to change for local environment EXAMPLE_CIDR 
shared_vpc_cidr_block  = "10.1.0.0/16"

route53_url_name       = "app-classic.EXAMPLE_SITE_NAME.nbspreview.com"

# this is latest generic windows in us-east-1 as of Oct 2024
# change if in another region
# ami                    = "ami-093693792d26e4373"

# May want to use a local aws bucket, this could be the same bucket as the
# terraform backend - this will hold application zip file AND RDS s3 dump
# artifacts_bucket_name  = "cdc-nbs-shared-software"
artifacts_bucket_name  = "EXAMPLE_BUCKET_NAME"

# ec2 classic application, must match Database snapshot version 
# deployment_package_key = "wildfly-10.0.0.Final-6.0.16.zip"

################################################################
# NBS 7 (Modern) 
################################################################

# Modernization Infrastructure
# VPC Variables
modern-cidr            = "10.OCTET2a.0.0/16"
modern-azs             = ["us-east-1a", "us-east-1b"]
modern-private_subnets = ["10.OCTET2a.1.0/24", "10.OCTET2a.3.0/24"]
modern-public_subnets  = ["10.OCTET2a.2.0/24", "10.OCTET2a.4.0/24"]

# EKS cluster Variables
# grab from login screen
aws_admin_role_name = "AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE"

