# Serial: 2024081301

# VPC for legacy application components
module "legacy-vpc" {

  source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/vpc?ref=release-7.11.0-rc1"

  #source      = "../../../../NEDSS-Infrastructure/terraform/aws/app-infrastructure/vpc"
  # SAMPLES
  #source      = "../app-infrastructure/vpc"

  # instead of doing this we will build classic specific resource_prefix
  # can still be overridden with name
  # name            = var.legacy-name
  # name            = "${var.resource_prefix}-classic"
  resource_prefix = "${var.resource_prefix}-classic"

  cidr            = var.legacy-cidr
  azs             = var.legacy-azs
  private_subnets = var.legacy-private_subnets
  public_subnets  = var.legacy-public_subnets

  create_igw             = var.legacy-create_igw
  enable_nat_gateway     = var.legacy-enable_nat_gateway
  single_nat_gateway     = var.legacy-single_nat_gateway
  one_nat_gateway_per_az = var.legacy-one_nat_gateway_per_az

  enable_dns_hostnames = var.legacy-enable_dns_hostnames
  enable_dns_support   = var.legacy-enable_dns_support

}
