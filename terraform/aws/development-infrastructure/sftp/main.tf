
resource "aws_iam_role" "transfer_logging" {
  name = "transfer-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "transfer.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "transfer_logging_policy" {
  role       = aws_iam_role.transfer_logging.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess"
}


resource "aws_dynamodb_table" "hl7_errors" {
  name         = "hl7-error-log"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "FileName"

  attribute {
    name = "FileName"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = false
  }
}

resource "aws_sns_topic" "error" {
  name = "hl7-error-topic"
}

resource "aws_sns_topic" "success" {
  name = "hl7-success-topic"
}

resource "aws_sns_topic" "summary" {
  name = "hl7-summary-topic"
}

resource "aws_transfer_server" "sftp" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols               = ["SFTP"]
  endpoint_type           = "PUBLIC"
  logging_role            = aws_iam_role.transfer_logging.arn
}

resource "aws_s3_bucket" "hl7" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "site_folders" {
  for_each = { for site, pubs in var.sites : site => pubs if var.enable_sftp }
  bucket   = aws_s3_bucket.hl7.id
  key      = "sites/${each.key}/"
}

resource "aws_s3_object" "publisher_folders" {
  for_each = var.enable_sftp ? merge([
    for site, pubs in var.sites : {
      for pub in pubs :
      "${site}/${pub}" => {
        site = site
        pub  = pub
      }
    }
  ]...) : {}

  bucket = aws_s3_bucket.hl7.id
  key    = "sites/${each.value.site}/${each.value.pub}/"
}

resource "aws_s3_object" "inbox_folders" {
  for_each = { for site, pubs in var.sites : site => pubs if var.enable_sftp }
  bucket   = aws_s3_bucket.hl7.id
  key      = "sites/${each.key}/inbox/"
}

resource "tls_private_key" "user_keys" {
  for_each = var.enable_sftp ? toset(flatten([for site, pubs in var.sites : [for pub in pubs : "${site}/${pub}"]])) : []
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "random_password" "user_passwords" {
  for_each = tls_private_key.user_keys
  length           = 16
  special          = true
  #override_characters = "!@#%&*"
}

resource "aws_secretsmanager_secret" "user_secrets" {
  for_each = tls_private_key.user_keys
  name     = "sftp/${each.key}"
}

resource "aws_secretsmanager_secret_version" "user_secrets_version" {
  for_each      = tls_private_key.user_keys
  secret_id     = aws_secretsmanager_secret.user_secrets[each.key].id
  secret_string = random_password.user_passwords[each.key].result
}

resource "aws_transfer_user" "sftp" {
  for_each = var.enable_sftp ? tls_private_key.user_keys : {}

  #server_id           = aws_transfer_server.sftp[0].id
  server_id           = aws_transfer_server.sftp.id
  user_name           = replace(each.key, "/", "_")
  role                = aws_iam_role.sftp_user[split("/", each.key)[0]].arn
  home_directory_type = "LOGICAL"
#  home_directory_mappings = [
#    {
#      entry  = "/"
#    }
#  ]
  #ssh_public_key_body = each.value.public_key_openssh
  #password            = random_password.user_passwords[each.key].result
}

resource "random_password" "admin_passwords" {
  for_each = var.enable_sftp ? var.sites : {}
  length           = 20
  special          = true
  #override_characters = "!@#%&*"
}

resource "aws_secretsmanager_secret" "admin_secrets" {
  for_each = var.enable_sftp ? var.sites : {}
  name     = "sftp_admins/${each.key}"
}

resource "aws_secretsmanager_secret_version" "admin_secrets_version" {
  for_each      = var.enable_sftp ? var.sites : {}
  secret_id     = aws_secretsmanager_secret.admin_secrets[each.key].id
  secret_string = random_password.admin_passwords[each.key].result
}

resource "aws_transfer_user" "site_admin" {
  for_each = var.enable_sftp ? var.sites : {}

  #server_id           = aws_transfer_server.sftp[0].id
  server_id           = aws_transfer_server.sftp.id
  user_name           = "admin_${each.key}"
  role                = aws_iam_role.sftp_user[each.key].arn
  home_directory_type = "LOGICAL"
  #home_directory_mappings = [
  #  {
  #    entry  = "/"
  #    target = "/${var.bucket_name}/sites/${each.key}"
  #  }
  #]
  #password = random_password.admin_passwords[each.key].result
}

output "sftp_usernames_and_dirs" {
  value = {
    for key, user in aws_transfer_user.sftp :
    key => {
      user_name   = user.user_name
      home_dir    = user.home_directory_mappings[0].target
      public_key  = tls_private_key.user_keys[key].public_key_openssh
      private_key = tls_private_key.user_keys[key].private_key_pem
      password    = random_password.user_passwords[key].result
    }
  }
  sensitive = true
}

output "site_admins" {
  value = {
    for key, user in aws_transfer_user.site_admin :
    key => {
      user_name = user.user_name
      home_dir  = user.home_directory_mappings[0].target
      password  = random_password.admin_passwords[key].result
    }
  }
  sensitive = true
}

resource "local_file" "sftp_credentials_csv" {
  content = <<EOT
username,password,ssh_key
${join("\n", [
  for key, val in aws_transfer_user.sftp :
  "${val.user_name},${random_password.user_passwords[key].result},${tls_private_key.user_keys[key].public_key_openssh}"
])}
EOT

  filename = "${path.module}/sftp_credentials.csv"
}

resource "aws_iam_role" "sftp_user" {
  for_each = {
    for key in keys(var.sites) :
    key => key
  }

  name = "sftp_user_${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "transfer.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "sftp_user_policy" {
  for_each = aws_iam_role.sftp_user

  name = "SftpUserPolicy-${each.key}"
  role = each.value.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      Resource = "*"
    }]
  })
}

