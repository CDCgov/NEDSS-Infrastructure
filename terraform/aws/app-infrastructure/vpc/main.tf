locals {
  resource_name = var.name != "" ? var.name : "${var.resource_prefix}-vpc"
}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "~> 5.0"
  name            = local.resource_name
  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  create_igw             = var.create_igw
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_dns_hostnames = var.enable_dns_hostnames 
  enable_dns_support = var.enable_dns_support 

  manage_default_security_group = var.manage_default_security_group
  manage_default_route_table = var.manage_default_route_table
  manage_default_network_acl = var.manage_default_network_acl
  map_public_ip_on_launch = var.map_public_ip_on_launch 
}