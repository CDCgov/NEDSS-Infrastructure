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

domain_name = "EXAMPLE_SITE_NAME.nbspreview.com"
sub_domain_name = "EXAMPLE_SITE_NAME"


################################################################
# NBS 6 (Classic) 
################################################################

# Common
# Legacy Infrastructure (grab all of these from existing environment)
# VPC Variables
# legacy-name                   = "cdc-nbs-legacy-vpc"
legacy-cidr                       = "10.OCTET2b.0.0/16"
# legacy-vpc-id                     = "vpc-LEGACY-EXAMPLE"
# legacy_vpc_private_route_table_id = "rtb-PRIVATE-EXAMPLE"
# legacy_vpc_public_route_table_id  = "rtb-PUBLIC-EXAMPLE"
legacy-azs                    = ["us-east-1a", "us-east-1b"]
legacy-private_subnets        = ["10.OCTET2b.1.0/24", "10.OCTET2b.3.0/24"]
legacy-public_subnets         = ["10.OCTET2b.2.0/24", "10.OCTET2b.4.0/24"]


#legacy-create_igw             = true
#legacy-enable_nat_gateway     = true
#legacy-single_nat_gateway     = true
#legacy-one_nat_gateway_per_az = false
#legacy-enable_dns_hostnames   = true
#legacy-enable_dns_support     = true
load_balancer_internal        = false

# Tags
tags = {
  "Project"     = "NBS"
  "Environment" = "EXAMPLE_ENVIRONMENT"
  "Owner"       = "CDC"
  "Terraform"   = "true"
}



########################
# Classic on container
#deploy_on_ecs          = true
deploy_on_ecs         = false
deploy_alb_dns_record = true
docker_image          = "quay.io/us-cdcgov/cdc-nbs-modernization/nbs6:6.0.16"
#docker_image           = "${var.shared_services_accountid}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/cdc-nbs-legacy/nbs6:latest"
nbs_github_release_tag = "latest"


########################
# Classic EC2 instance

# this is latest generic windows in us-east-1 as of Oct 2024
ami                    = "ami-093693792d26e4373"

ec2_instance_type      = "m5.large"
ec2_key_name           = "cdc-nbs-ec2-EXAMPLE_SITE_NAME"
# This needs to change for local environment EXAMPLE_CIDR 
shared_vpc_cidr_block  = "10.1.0.0/16"
db_instance_type       = "db.m6i.large"
db_snapshot_identifier = "cdc-nbs-6-0-16-test"
route53_url_name       = "app-classic.EXAMPLE_SITE_NAME.nbspreview.com"
create_cert            = true
# May want to use a local aws bucket, this could be the same bucket as the
# terraform backend 
artifacts_bucket_name  = "cdc-nbs-shared-software"
deployment_package_key = "wildfly-10.0.0.Final-6.0.16.zip"
# XXX - mossc - is this still used or are we doing something with resource
# prefix?????
nbs_db_dns = "nbs-db"

#use_ecr_pull_through_cache=true 
external_cidr_blocks = []

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
eks_instance_type = "m5.large"
# grab from login screen
aws_admin_role_name = "AWSReservedSSO_AWSAdministratorAccess_EXAMPLE_ROLE"

# S3 buckets
#fluentbit_bucket_prefix = "EXAMPLE-fluentbit-bucket"
#fluentbit_bucket_name = "EXAMPLE-fluentbit-logs"
