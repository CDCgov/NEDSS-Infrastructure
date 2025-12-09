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
