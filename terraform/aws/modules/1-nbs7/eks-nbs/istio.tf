locals {
  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
}

resource "kubernetes_namespace" "istio_system" {
  count    = var.deploy_istio_helm == "true" ? 1 : 0
  provider = kubernetes
  metadata {
    name = "istio-system"
  }

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "istio_ingress" {
  count    = var.deploy_istio_helm == "true" ? 1 : 0
  provider = kubernetes
  metadata {
    name = "istio-ingress"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_base" {
  count            = var.deploy_istio_helm == "true" ? 1 : 0
  provider         = helm
  repository       = local.istio_charts_url
  chart            = "base"
  name             = "istio-base"
  namespace        = "istio"
  version          = var.istio_version
  create_namespace = true

  depends_on = [kubernetes_namespace.istio_system]
}

resource "helm_release" "istiod" {
  count            = var.deploy_istio_helm == "true" ? 1 : 0
  provider         = helm
  repository       = local.istio_charts_url
  chart            = "istiod"
  name             = "istiod"
  namespace        = kubernetes_namespace.istio_system[count.index].id
  create_namespace = true
  version          = var.istio_version
  depends_on       = [helm_release.istio_base]
}

resource "helm_release" "ingress-gateway" {
  count      = var.deploy_istio_helm == "true" ? 1 : 0
  provider   = helm
  repository = local.istio_charts_url
  chart      = "gateway"
  name       = "istio-ingressgateway"
  namespace  = "istio-ingress"
  version    = var.istio_version
  depends_on = [helm_release.istio_base]


  values = [
    <<-EOF
    podAnnotations:
      # prometheus.io/port: "15020"
      # prometheus.io/scrape: "true"
      # prometheus.io/path: "/stats/prometheus"
      inject.istio.io/templates: "gateway"
      sidecar.istio.io/inject: "true"
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    labels:
      app: NBS
      istio: ingressgateway 
    EOF
  ]

}
