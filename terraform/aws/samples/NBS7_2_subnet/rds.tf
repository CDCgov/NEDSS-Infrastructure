module "rds" {
    source = "git::https://github.com/CDCgov/NEDSS-Infrastructure.git//terraform/aws/app-infrastructure/efs?ref=CNPT-1612-split-rds"
    resource_prefix = var.resource_prefix
    db_instance_type = var.db_instance_type
    db_snapshot_identifier = var.db_snapshot_identifier
    vpc_id = data.aws_vpc.vpc_1.id
    private_subnet_ids = local.list_db_subnet_ids
}
