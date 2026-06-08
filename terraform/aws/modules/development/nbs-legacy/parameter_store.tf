resource "aws_ssm_parameter" "odse_user" {
  description = "Database user for odse"
  name        = "/${var.resource_prefix}-app-server/odse_user"
  type        = "SecureString"
  value       = var.odse_user
  key_id      = var.param_store_key_id
}

resource "aws_ssm_parameter" "odse_pass" {
  description = "Database password for odse"
  name        = "/${var.resource_prefix}-app-server/odse_pass"
  type        = "SecureString"
  value       = var.odse_pass
  key_id      = var.param_store_key_id
}

resource "aws_ssm_parameter" "rdb_user" {
  description = "Database user for rdb"
  name        = "/${var.resource_prefix}-app-server/rdb_user"
  type        = "SecureString"
  value       = var.rdb_user
  key_id      = var.param_store_key_id
}

resource "aws_ssm_parameter" "rdb_pass" {
  description = "Database password for rdb"
  name        = "/${var.resource_prefix}-app-server/rdb_pass"
  type        = "SecureString"
  value       = var.rdb_pass
  key_id      = var.param_store_key_id
}

resource "aws_ssm_parameter" "srte_user" {
  description = "Database user for srte"
  name        = "/${var.resource_prefix}-app-server/srte_user"
  type        = "SecureString"
  value       = var.srte_user
  key_id      = var.param_store_key_id
}

resource "aws_ssm_parameter" "srte_pass" {
  description = "Database password for srte"
  name        = "/${var.resource_prefix}-app-server/srte_pass"
  type        = "SecureString"
  value       = var.srte_pass
  key_id      = var.param_store_key_id
}

resource "aws_ssm_parameter" "phcrimporter_user" {
  description = "Database password for srte"
  name        = "/${var.resource_prefix}-app-server/phcrimporter_user"
  type        = "SecureString"
  value       = var.phcrimporter_user
  key_id      = var.param_store_key_id
}

