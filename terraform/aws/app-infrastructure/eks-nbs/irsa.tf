module "efs_cni_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "efs-cni"

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:aws-node",
        "kube-system:efs-csi-controller-sa"
      ]
    }
  }
}
