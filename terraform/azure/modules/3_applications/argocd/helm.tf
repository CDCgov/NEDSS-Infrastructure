
locals {
  argocd_global_image_repo = "quay.io/argoproj/argocd"
  argocd_redis_main_image_repo = "public.ecr.aws/docker/library/redis"
  argocd_redis_exporter_image_repo = "public.ecr.aws/bitnami/redis-exporter"    
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

  # set image repo reference
  set {
    name  = "global.image.repository"
    value = local.argocd_global_image_repo
  }

  set {
    name  = "redis.image.repository"
    value = local.argocd_redis_main_image_repo
  }

  set {
    name  = "redis.exporter.image.repository"
    value = local.argocd_redis_main_image_repo
  }

   set {
    name  = "redis-ha.image.repository"
    value = local.argocd_redis_main_image_repo
  }

  set {
    name  = "redis-ha.exporter.image.repository"
    value = local.argocd_redis_main_image_repo
  }
}

