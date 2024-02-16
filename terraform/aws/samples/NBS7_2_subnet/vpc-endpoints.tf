# module "vpc-endpoints" {
#   source             = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/vpc-endpoints-nbs?ref=v1.1.9-DEV"
#   resource_prefix    = var.resource_prefix
#   tags               = var.tags
#   vpc_id             = data.aws_vpc.vpc_1.id
#   vpc_cidr_block     = data.aws_vpc.vpc_1.cidr_block
#   private_subnet_ids = local.list_subnet_ids
# }
