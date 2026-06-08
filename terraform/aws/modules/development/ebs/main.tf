resource "aws_ebs_encryption_by_default" "example" {
  enabled = var.enable_ebs_encryption_by_default
}
