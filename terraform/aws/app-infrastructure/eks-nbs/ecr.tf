# This creates a pull through cache for public AWS ECR, quay, and dockerhub
resource "aws_ecr_pull_through_cache_rule" "example" {
    count = var.use_ecr_pull_through_cache ? 1 : 0
    ecr_repository_prefix = "ecr-public"
    upstream_registry_url = "public.ecr.aws"
}

resource "aws_ecr_pull_through_cache_rule" "example" {
    count = var.use_ecr_pull_through_cache ? 1 : 0
    ecr_repository_prefix = "quay-public"
    upstream_registry_url = "quay.io"
}

resource "aws_ecr_pull_through_cache_rule" "example" {
    count = var.use_ecr_pull_through_cache ? 1 : 0
    ecr_repository_prefix = "dockerhub-public"
    upstream_registry_url = "registry-1.docker.io"
}