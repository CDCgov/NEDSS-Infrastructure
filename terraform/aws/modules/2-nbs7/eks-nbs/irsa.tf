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
  create                     = var.enable_cert_manager
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
    policy = try(aws_iam_policy.otel_collector_irsa_policy[0].arn, null)
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
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.otel_collector_s3_bucket_name}"
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.otel_collector_s3_bucket_name}/*"
      }
    ]
  })
}

module "datacompare_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = ">=6.2.3, <7.0.0"

  name   = "${local.eks_name}-datacompare-role"
  create = var.create_datacompare_irsa

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = var.datacompare_namespace_and_service
    }
  }

  policies = {
    policy = try(aws_iam_policy.datacompare_irsa_policy[0].arn, null)
  }
}

resource "aws_iam_policy" "datacompare_irsa_policy" {
  count       = var.create_datacompare_irsa ? 1 : 0
  name        = "${local.eks_name}-datacompare-policy"
  description = "DataCompare S3 access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.datacompare_s3_bucket_name}"
      },
      {
        Action = [
          "s3:GetObjectAttributes",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.datacompare_s3_bucket_name}/${var.datacompare_s3_bucket_keyname_prefix}*"
      }
    ]
  })
}

# ──────────────────────────────────────────────────────────
# Cluster Autoscaler IRSA
# ──────────────────────────────────────────────────────────

module "cluster_autoscaler_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = ">=6.2.3, <7.0.0"

  name   = "${local.eks_name}-cluster-autoscaler"
  create = var.create_cluster_autoscaler_irsa

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler-aws-cluster-autoscaler"]
    }
  }

  policies = {
    policy = try(aws_iam_policy.cluster_autoscaler_irsa_policy[0].arn, null)
  }
}

resource "aws_iam_policy" "cluster_autoscaler_irsa_policy" {
  count       = var.create_cluster_autoscaler_irsa ? 1 : 0
  name        = "${local.eks_name}-cluster-autoscaler-policy"
  description = "Cluster Autoscaler permissions for EKS node group scaling"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ClusterAutoscalerDescribe"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "ClusterAutoscalerScale"
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = ["*"]
        Condition = {
          StringEquals = {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled"                  = "true"
            "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_autoscaler_cluster_name}" = "owned"
          }
        }
      }
    ]
  })
}