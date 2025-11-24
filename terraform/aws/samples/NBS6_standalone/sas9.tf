# Serial: 2025041001
#NOTE: create a ssh key pair before deploying this module

module "sas9" {
  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/sas9?ref=release-7.11.0-rc1"
  #source  = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/sas9"
  sas_ami              = var.sas_ami
  vpc_cidr_block       = var.legacy-cidr
  vpn_cidr_block       = var.shared_vpc_cidr_block
  sas_keypair_name     = var.sas_keypair_name
  sas_kms_key_id       = var.sas_kms_key_id
  sas_root_volume_size = var.sas_root_volume_size
  sas_instance_type    = var.sas_instance_type
  sas_subnet_id        = module.legacy-vpc.private_subnets[0]
  sas_vpc_id           = module.legacy-vpc.vpc_id
  resource_prefix      = var.resource_prefix
}













