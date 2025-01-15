# Serial: 2025011501

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

# delegated zone hosted in the local account manually created
zone_id = "EXAMPLE_ZONE_ID"

# XXX - testing for STLT
create_route53_hosted_zone = false

# May generate error when Route53 zone is hosted in another AWS account
#hosted-zone-id = "EXAMPLE_HOSTED_ZONE_ID" 
# only use this if you are hosting DNS within this account OR have cross
# account access to the account which is authoritative for domain
#hosted-zone-account = "EXAMPLE_ACCOUNT_ID"

domain_name = "EXAMPLE_SITE_NAME.nbspreview.com"
sub_domain_name = "EXAMPLE_SITE_NAME"

# these cidr blocks will be added to security groups to allow direct access
external_cidr_blocks = []

nbs_db_dns = "nbs-db.private-EXAMPLE_SITE.EXAMPLE_DOMAIN

# change this if we are getting artifacts from a bucket in this account
#nbs_local_bucket = true
nbs_local_bucket = false

################################################################
# NBS 6 (Classic) 
################################################################

# Legacy Infrastructure 

# VPC Variables
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
# this needs to match the local DNS snapshot name, the snapshot should be
# created in advance, we suggest the snapshot name match the name from
# image shared in the original account
# db_snapshot_identifier = "cdc-nbs-6-0-16-test"

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
# that was copied into your local <artifacts_bucket_name>/nbs/<fn.zip>
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
# grab from login screen if using SSO or 
# aws sts get-caller-identity 
aws_admin_role_name = "AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE"
