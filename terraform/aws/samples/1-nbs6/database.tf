module "rds" {

  source = "../../development-infrastructure/rds"  

  db_instance_type            = var.db_instance_type
  db_snapshot_identifier      = var.db_snapshot_identifier
  private_subnet_ids          = var.database_subnets
  manage_master_user_password = var.manage_master_user_password
  app_security_group_id       = var.ingress_security_group_id  
  ingress_vpc_cidr_blocks = "${data.aws_vpc.selected.cidr_block},${var.additional_ingress_cidr}"

  vpc_id          = data.aws_vpc.selected.id
  resource_prefix = var.resource_prefix 

}
