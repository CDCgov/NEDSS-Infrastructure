output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_ids[0]
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_ids[0]
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}