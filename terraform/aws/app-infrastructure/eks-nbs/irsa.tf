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

module "datacompare_irsa_role" {  
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = ">=6.2.3, <7.0.0"

  name                       = "${local.eks_name}-datacompare-role" 
  create                     = var.create_datacompare_irsa  

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = var.datacompare_namespace_and_service
    }
  }
  policies ={
   policy = aws_iam_policy.datacompare_irsa_policy[0].arn
  } 
}

resource "aws_iam_policy" "datacompare_irsa_policy" {
  count = var.create_datacompare_irsa ? 1 : 0
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