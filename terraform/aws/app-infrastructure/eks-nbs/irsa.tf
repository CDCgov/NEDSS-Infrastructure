module "efs_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name             = "${local.eks_name}-efs-cni" #defined in main.tf
  create_role           = true
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
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name                  = "${local.eks_name}-cert-manager-cni" #defined in main.tf
  create_role                = true
  attach_cert_manager_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
}
