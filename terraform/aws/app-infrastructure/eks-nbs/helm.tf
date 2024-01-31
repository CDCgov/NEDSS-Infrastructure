locals {
  efs_main_image_repo = var. use_ecr_pull_through_cache ? "${aws_ecr_pull_through_cache_rule.ecr_public[0].registry_id}/efs-csi-driver/amazon/aws-efs-csi-driver" : "public.ecr.aws/efs-csi-driver/amazon/aws-efs-csi-driver"
  efs_side_liveness_image_repo = var. use_ecr_pull_through_cache ? "${aws_ecr_pull_through_cache_rule.ecr_public[0].registry_id}/eks-distro/kubernetes-csi/livenessprobe" : "public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe"
  efs_side_nodedriverregistrar_image_repo = var. use_ecr_pull_through_cache ? "${aws_ecr_pull_through_cache_rule.ecr_public[0].registry_id}/eks-distro/kubernetes-csi/node-driver-registrar" : "public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar"
  efs_side_csiprovisioner_image_repo = var. use_ecr_pull_through_cache ? "${aws_ecr_pull_through_cache_rule.ecr_public[0].registry_id}/eks-distro/kubernetes-csi/external-provisioner" : "public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner"  
}

# Create efs driver using helm
resource "helm_release" "efs" {
  provider         = helm
  name             = "aws-efs-csi-driver"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart            = "aws-efs-csi-driver"
  wait             = true
  create_namespace = false

  # set image repo reference
  set {
    name  = "image.repository"
    value = local.efs_main_image_repo
  }

  set {
    name  = "sidecars.livenessProbe.image.repository"
    value = local.efs_side_liveness_image_repo
  }

  set {
    name  = "sidecars.nodeDriverRegistrar.image.repository"
    value = local.efs_side_nodedriverregistrar_image_repo
  }

  set {
    name  = "sidecars.csiProvisioner.image.repository"
    value = local.efs_side_csiprovisioner_image_repo
  }

  # set irsa roles
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
