resource "helm_release" "cert_manager" {
  count            = var.enable_cert_manager ? 1 : 0
  provider         = helm
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.0"
  wait             = true
  create_namespace = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "serviceAccount.annotations.azure\\.workload\\.identity/client-id"
      value = azurerm_user_assigned_identity.cert_manager[count.index].client_id
    },
    {
      name  = "securityContext.fsGroup"
      value = 1001
    }
  ]

  depends_on = [module.aks]
}