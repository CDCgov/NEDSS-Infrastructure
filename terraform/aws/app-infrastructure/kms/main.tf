module "kms" {
  source              = "terraform-aws-modules/kms/aws"
  version             = "4.1.1"
  description         = var.description
  key_usage           = var.key_usage
  enable_key_rotation = var.enable_key_rotation
  create              = true

  # Policy  
  key_administrators = var.key_administrators
  key_users          = var.key_users
  key_service_users  = var.key_service_users

  # Values to modify for custom policies
  key_statements = var.key_statements

  # Aliases
  aliases = var.aliases
}

