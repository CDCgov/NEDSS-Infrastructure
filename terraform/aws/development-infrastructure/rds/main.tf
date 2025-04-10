# NBS backend RDS database instance
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier = "${var.resource_prefix}-rds-mssql"

  engine               = "sqlserver-se"
  engine_version       = "15.00"
  family               = "sqlserver-se-15.0" # DB parameter group
  major_engine_version = "15.00"             # DB option group
  instance_class       = var.db_instance_type
  manage_master_user_password = var.manage_master_user_password

  //allocated_storage     = 20
  //max_allocated_storage = 100

  # Encryption at rest is not available for DB instances running SQL Server Express Edition
  storage_encrypted = true

  //username = "admin"
  //port     = 1433


  multi_az = false
  # db_subnet_group_name   = "legacy-db-subnet-group"
  # create DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.private_subnet_ids
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled = false
  create_monitoring_role       = false
  /*
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
*/
  options                   = []
  license_model             = "license-included"
  character_set_name        = "SQL_Latin1_General_CP1_CI_AS"
  snapshot_identifier       = var.db_snapshot_identifier
  apply_immediately = var.apply_immediately

# Enabling Custom DB parameter group and its parameter
  create_db_parameter_group       = true
  parameter_group_name            = var.parameter_group_name
  parameter_group_description     = var.parameter_group_description
  parameters                      = var.parameters
  #parameter_group_use_name_prefix = false
  parameter_group_use_name_prefix = true
}

# Security group for NBS backend RDS database server
module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name         = "${var.resource_prefix}-rds-sg"
  description  = "Security group for RDS instance"
  vpc_id       = var.vpc_id
  egress_rules = ["all-all"]

  # Open for application server source security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 1433
      to_port                  = 1433
      protocol                 = "tcp"
      description              = "MSSQL RDS instance access from EC2"
      source_security_group_id = var.app_security_group_id
    }
  ]

  # Open for shared services and legacy VPC cidr block
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL RDS instance access from within VPCs"
      cidr_blocks = "${var.ingress_vpc_cidr_blocks}"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1

}
