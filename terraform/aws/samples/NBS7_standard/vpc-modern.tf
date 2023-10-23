# VPC for modernization application components
module "modernization-vpc" {
  source          = "../app-infrastructure/vpc"
  name            = var.modern-name
  cidr            = var.modern-cidr
  azs             = var.modern-azs
  private_subnets = var.modern-private_subnets
  public_subnets  = var.modern-public_subnets

  create_igw             = var.modern-create_igw
  enable_nat_gateway     = var.modern-enable_nat_gateway
  single_nat_gateway     = var.modern-single_nat_gateway
  one_nat_gateway_per_az = var.modern-one_nat_gateway_per_az

  enable_dns_hostnames  = var.modern-enable_dns_hostnames 
  enable_dns_support  = var.modern-enable_dns_support

}

# VPC for legacy application components
#module "legacy-vpc" {
#  source          = "../app-infrastructure/vpc"
#  name            = var.legacy-name
#  cidr            = var.legacy-cidr
#  azs             = var.legacy-azs
#  private_subnets = var.legacy-private_subnets
#  public_subnets  = var.legacy-public_subnets
#
#  create_igw             = var.legacy-create_igw
#  enable_nat_gateway     = var.legacy-enable_nat_gateway
#  single_nat_gateway     = var.legacy-single_nat_gateway
#  one_nat_gateway_per_az = var.legacy-one_nat_gateway_per_az
#
#  enable_dns_hostnames  = var.legacy-enable_dns_hostnames 
#  enable_dns_support  = var.legacy-enable_dns_support
#}

#Add VPC peering between two resources
resource "aws_vpc_peering_connection" "peering_connection" {
  peer_owner_id = var.target_account_id
  peer_vpc_id   = module.modernization-vpc.vpc_id
  vpc_id        = var.legacy-vpc-id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between legacy-vpc and modern-vpc"
  }
}


# Add routes to route to exsiting route tables (currently)
resource "aws_route" "modern_to_legacy_private"{
  route_table_id = module.modernization-vpc.private_route_table_id
  destination_cidr_block = var.legacy-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  depends_on = [module.modernization-vpc]
}

resource "aws_route" "modern_to_legacy_public"{
  route_table_id = module.modernization-vpc.public_route_table_id
  destination_cidr_block = var.legacy-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  depends_on = [module.modernization-vpc]
}

resource "aws_route" "legacy_to_modern_private"{
  route_table_id = var.legacy_vpc_private_route_table_id
  destination_cidr_block = var.modern-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
#  depends_on = [module.legacy-vpc]
}

resource "aws_route" "legacy_to_modern_public"{
  route_table_id = var.legacy_vpc_public_route_table_id
  destination_cidr_block = var.modern-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  #depends_on = [module.legacy-vpc]
}
