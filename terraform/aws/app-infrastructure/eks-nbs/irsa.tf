module "efs_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = ">=6.2.3, <7.0.0"

  name                  = "${local.eks_name}-efs-cni" #defined in main.tf
  create                = true
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:aws-node",
        "kube-system:efs-csi-controller-sa"
      ]
    }
  }
}

module "cert_manager_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = ">=6.2.3, <7.0.0"

  name                       = "${local.eks_name}-cert-manager-cni" #defined in main.tf
  create                     = true
  attach_cert_manager_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

  cert_manager_hosted_zone_arns = var.cert_manager_hosted_zone_arns
}

module "otel_collector_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = ">=6.2.3, <7.0.0"

  name   = "${local.eks_name}-otel-collector-role"
  create = var.create_otel_collector_irsa

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = var.otel_collector_namespace_and_service
    }
  }

  policies = {
    policy = aws_iam_policy.otel_collector_irsa_policy[0].arn
  }
}

resource "aws_iam_policy" "otel_collector_irsa_policy" {
  count       = var.create_otel_collector_irsa ? 1 : 0
  name        = "${local.eks_name}-otel-collector-s3-policy"
  description = "OTEL Collector S3 write access for container log archival"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OtelLogsS3Write"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.otel_collector_s3_bucket_name}",
          "arn:aws:s3:::${var.otel_collector_s3_bucket_name}/*"
        ]
      }
    ]
  })
}