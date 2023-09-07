data "aws_caller_identity" "current" {}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}-${random_string.random.result}"
  tags   = merge(tomap({ "Name" = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}-${random_string.random.result}" }), var.tags)
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  depends_on = [aws_s3_bucket.log_bucket]
  bucket     = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  depends_on = [aws_s3_bucket.log_bucket, aws_s3_bucket_public_access_block.public_access_block]
  bucket     = aws_s3_bucket.log_bucket.id
  acl        = "private"
}
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  depends_on = [aws_s3_bucket.log_bucket]
  bucket     = aws_s3_bucket.log_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}