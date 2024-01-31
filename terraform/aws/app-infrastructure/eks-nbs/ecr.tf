# This creates a pull through cache for public AWS ECR, quay
# Note dockerhub requires user credentials and was thus not added
resource "aws_ecr_pull_through_cache_rule" "ecr_public" {
    count = var.use_ecr_pull_through_cache ? 1 : 0
    ecr_repository_prefix = "ecr-public"
    upstream_registry_url = "public.ecr.aws"
}

resource "aws_ecr_pull_through_cache_rule" "quay" {
    count = var.use_ecr_pull_through_cache ? 1 : 0
    ecr_repository_prefix = "quay-public"
    upstream_registry_url = "quay.io"
}
