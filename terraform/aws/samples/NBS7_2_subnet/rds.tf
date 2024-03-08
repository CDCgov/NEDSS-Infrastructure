module "rds" {
    source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/development-infrastructure/rds?ref=v1.2.2-DEV"
    resource_prefix = var.resource_prefix
    db_instance_type = var.db_instance_type
    db_snapshot_identifier = var.db_snapshot_identifier
    vpc_id = data.aws_vpc.vpc_1.id
    private_subnet_ids = local.list_db_subnet_ids
    ingress_vpc_cidr_blocks = var.ingress_vpc_cidr_blocks
}
