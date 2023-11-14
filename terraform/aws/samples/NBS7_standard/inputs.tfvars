# Account variables
# updated github global secrets to remove single quoting
#
#
# Search and replace SITE_NAME and EXAMPLE_DOMAIN
# OCTET2a, OCTET2b, OCTET2shared
# search for all other EXAMPLE

# Account variables
target_account_id = ""

hosted-zone-id = ""
hosted-zone-iam-arn = ""

artifacts_bucket_name = ""
kms_arn_shared_services_bucket = ""


# Domain name
domain_name                = "SITE_NAME.EXAMPLE_DOMAIN.com"
sub_domain_name            = "SITE_NAME"
create_route53_hosted_zone = false

# Modernization Infrastructure
# VPC Variables
modern-name =  "cdc-nbs-modern-vpc"
modern-cidr = "10.OCTET2a.0.0/16"
modern-azs = ["us-east-1a", "us-east-1b"]
modern-private_subnets = ["10.OCTET2a.1.0/24", "10.OCTET2a.3.0/24"]
modern-public_subnets = ["10.OCTET2a.2.0/24", "10.OCTET2a.4.0/24"]
modern-create_igw = true
modern-enable_nat_gateway = true
modern-single_nat_gateway = true
modern-one_nat_gateway_per_az = false
modern-enable_dns_hostnames = true
modern-enable_dns_support = true
# unused in modern
# modern-vpc-id = ""

# Legacy Infrastructure
# VPC Variables
legacy-name = "cdc-nbs-legacy-vpc"
legacy-cidr = "10.OCTET2b.0.0/16"
legacy-azs = ["us-east-1a", "us-east-1b"]
legacy-private_subnets = ["10.OCTET2b.1.0/24", "10.OCTET2b.3.0/24"]
legacy-public_subnets = ["10.OCTET2b.2.0/24", "10.OCTET2b.4.0/24"]
legacy-create_igw = true
legacy-enable_nat_gateway = true
legacy-single_nat_gateway = true
legacy-one_nat_gateway_per_az = false
legacy-enable_dns_hostnames = true
legacy-enable_dns_support = true
# README grab all of these from existing environment
legacy-vpc-id = "vpc-EXAMPLE"
legacy_vpc_private_route_table_id = "rtb-EXAMPLE"
legacy_vpc_public_route_table_id = "rtb-EXAMPLE"

# Tags
tags = {
    "Project"     = "NBS"
    "Environment" = "EXAMPLE"
    "Owner"       = "CDC"
    "Terraform" = "true"
  }

# Modern Variables
eks_disk_size = 100
eks_instance_types = ["m5.large"]
# grab from login screen
aws_admin_role_name = "AWSReservedSSO_AWSAdministratorAccess_EXAMPLE"

# Legacy EC2 instance
# README - add lookup of latest windows shared ami, differs per region
ami = "ami-069c45f40acdfe41e"
instance_type = "t3.large"
# README - precreated
ec2_key_name = "cdc-nbs-ec2-SITE_NAME"
shared_vpc_cidr_block = "10.OCTET2shared.0.0/16"
db_instance_type = "db.m6i.large"
create_cert = true
# changed legacy module so need to modify
# deployment_package_key = "nbs/wildfly-10.0.0.Final-6.0.15.zip"
deployment_package_key = ""
nbs_db_dns = "nbs-db"
route53_url_name = "app-classic.SITE_NAME.EXAMPLE_DOMAIN.com"
# README unused for modern
db_snapshot_identifier = ""

# tmp for msk
environment         = "development"
msk_ebs_volume_size = 20
