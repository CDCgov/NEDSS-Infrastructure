# locals {
#   efs_repository = use_ecr_pull_through_cache ? 
# }

# Create efs driver using helm
resource "helm_release" "efs" {
  provider         = helm
  name             = "aws-efs-csi-driver"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart            = "aws-efs-csi-driver"
  wait             = true
  create_namespace = false

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs_cni_irsa_role.iam_role_arn
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs_cni_irsa_role.iam_role_arn
  }

  depends_on = [ module.eks ]
}

# Create argocd for deployment
resource "helm_release" "argocd" {
  count    = var.deploy_argocd_helm == "true" ? 1 : 0
  provider         = helm
  name             = "argocd-release"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  wait             = true
  create_namespace = true

  depends_on = [ module.eks ]
}

# create cert manager release
resource "helm_release" "cert_manager" {
  provider         = helm
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.0"
  wait             = true
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  # Set values for OIDC
  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cert_manager_cni_irsa_role.iam_role_arn
  }

  set {
    name = "securityContext.fsGroup"
    value = 1001
  }

  depends_on = [ module.eks ]
}
