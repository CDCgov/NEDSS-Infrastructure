
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
  override_characters = "!@#%&*"
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

  server_id           = aws_transfer_server.sftp[0].id
  user_name           = replace(each.key, "/", "_")
  role                = aws_iam_role.sftp_user[split("/", each.key)[0]].arn
  home_directory_type = "LOGICAL"
  home_directory_mappings = [
    {
      entry  = "/"
      target = "/sites/${split("/", each.key)[0]}/${split("/", each.key)[1]}"
    }
  ]
  ssh_public_key_body = each.value.public_key_openssh
  password            = random_password.user_passwords[each.key].result
}

resource "random_password" "admin_passwords" {
  for_each = var.enable_sftp ? var.sites : {}
  length           = 20
  special          = true
  override_characters = "!@#%&*"
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

  server_id           = aws_transfer_server.sftp[0].id
  user_name           = "admin_${each.key}"
  role                = aws_iam_role.sftp_user[each.key].arn
  home_directory_type = "LOGICAL"
  home_directory_mappings = [
    {
      entry  = "/"
      target = "/${var.bucket_name}/sites/${each.key}"
    }
  ]
  password = random_password.admin_passwords[each.key].result
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
${join("
", [
    "user_type,site,publisher,user_name,home_directory,password,public_key",
    for key, user in aws_transfer_user.sftp :
    format(
      "publisher,%s,%s,%s,%s,%s,%s",
      split("/", key)[0],
      split("/", key)[1],
      user.user_name,
      jsonencode(user.home_directory_mappings[0].target),
      jsonencode(random_password.user_passwords[key].result),
      jsonencode(tls_private_key.user_keys[key].public_key_openssh)
    )
  ] ++ [
    for key, user in aws_transfer_user.site_admin :
    format(
      "admin,%s,-,%s,%s,%s,",
      key,
      user.user_name,
      jsonencode(user.home_directory_mappings[0].target),
      jsonencode(random_password.admin_passwords[key].result)
    )
  ])
  filename        = "sftp_credentials_audit.csv"
  file_permission = "0600"
}

