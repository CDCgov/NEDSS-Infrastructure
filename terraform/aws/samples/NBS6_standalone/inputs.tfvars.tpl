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
kms_arn_shared_services_bucket = "arn:aws:kms:us-east-1:EXAMPLE_SHARED_SERVICES_ACCOUNT:key/123456-789"

# Database users
odse_user = "EXAMPLE_USER1"
odse_pass = "EXAMPLE_USER1_PASSWORD"
rdb_user = "EXAMPLE_USER2"
rdb_pass = "EXAMPLE_USER2_PASSWORD"
srte_user = "EXAMPLE_USER3"
srte_pass = "EXAMPLE_USER3_PASSWORD"

# Domain name
domain_name = "EXAMPLE_SITE_NAME.nbspreview.com"
sub_domain_name = "EXAMPLE_SITE_NAME"
create_route53_hosted_zone = true

# May generate error when Route53 zone is hosted in another AWS account
hosted-zone-id = "EXAMPLE_HOSTED_ZONE_ID"
hosted-zone-iam-arn = "arn:aws:iam::EXAMPLE_SHARED_SERVICES_ACCOUNT:role/example-cross-account-role"



# Legacy Infrastructure (we will build)
# VPC Variables
# legacy-name                   = "cdc-nbs-legacy-vpc"
# legacy-vpc-id                     = "vpc-LEGACY-EXAMPLE"
# legacy_vpc_private_route_table_id = "rtb-PRIVATE-EXAMPLE"
# legacy_vpc_public_route_table_id  = "rtb-PUBLIC-EXAMPLE"
legacy-cidr                       = "10.OCTET2b.0.0/16"
legacy-azs                    = ["us-east-1a", "us-east-1b"]
legacy-private_subnets        = ["10.OCTET2b.1.0/24", "10.OCTET2b.3.0/24"]
legacy-public_subnets         = ["10.OCTET2b.2.0/24", "10.OCTET2b.4.0/24"]


legacy-create_igw             = true
legacy-enable_nat_gateway     = true
legacy-single_nat_gateway     = true
legacy-one_nat_gateway_per_az = false
legacy-enable_dns_hostnames   = true
legacy-enable_dns_support     = true
load_balancer_internal        = false

# Tags
tags = {
  "Project"     = "NBS"
  "Environment" = "EXAMPLE_ENVIRONMENT"
  "Owner"       = "CDC"
  "Terraform"   = "true"
}



# Classic on container
#deploy_on_ecs          = true
deploy_on_ecs         = false
deploy_alb_dns_record = true
docker_image          = "quay.io/us-cdcgov/cdc-nbs-modernization/nbs6:6.0.17"
#docker_image           = "${var.shared_services_accountid}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/cdc-nbs-legacy/nbs6:latest"
nbs_github_release_tag = "latest"

# Classic EC2 instance
ami                    = null
instance_type          = "m5.large"
ec2_key_name           = "cdc-nbs-ec2-EXAMPLE_SITE_NAME"
# This needs to change for local environment EXAMPLE_CIDR 
shared_vpc_cidr_block  = "10.3.0.0/16"
db_instance_type       = "db.m6i.large"
db_snapshot_identifier = "cdc-nbs-legacy-rds-mssql-6017-04112025"
route53_url_name       = "app-classic.EXAMPLE_SITE_NAME.nbspreview.com"
create_cert            = true
# May want to use a local aws bucket, this could be the same bucket as the
# terraform backend 
artifacts_bucket_name  = "cdc-nbs-shared-software"
deployment_package_key = "wildfly-10.0.0.Final-6.0.17.zip"
# XXX - mossc - is this still used or are we doing something with resource
# prefix?????
nbs_db_dns = "nbs-db"


#use_ecr_pull_through_cache=true 
external_cidr_blocks = []


## SAS Variables
sas_kms_key_id = "arn:aws:kms:us-east-1:EXAMPLE_SHARED_SERVICES_ACCOUNT:key/123456-789" # from shared-services
sas_keypair_name = "cdc-nbs-sas-EXAMPLE_SITE_NAME"