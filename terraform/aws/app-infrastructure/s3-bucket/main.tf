#create s3 bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "${var.bucket_prefix}"
  tags   = merge(tomap({ "Name" = "${aws_s3_bucket.log_bucket.id}" }), var.tags)
  force_destroy = var.force_destroy_log_bucket
}

# Enabled bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.versioning_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enabled block public access
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  depends_on = [aws_s3_bucket.log_bucket]
  bucket     = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# configure object lifecycle rule
resource "aws_s3control_bucket_lifecycle_configuration" "lifecyle_rules" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning]
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id = "default-lifecycle-policy"
    
    expiration {
      days = var.mark_object_for_delete_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.delete_noncurrent_objects
    }
    status = var.enable_default_bucket_lifecycle_policy
  }  
}
