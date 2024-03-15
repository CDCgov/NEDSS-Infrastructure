# Deploys linkerd, linkerd control plane and linkerd visualization dashboard 
# using external prometheus
# #############################################################
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "csels-nbs-dev-low-rg"
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "aks_cluster_auth" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name

provider "helm" {
  kubernetes {
  host                   = data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_cluster.kube_config[0].cluster_ca_certificate)
}
#############################################################

# linkerd helm release
resource "helm_release" "linkerd_crds" {
  name            = "linkerd-crds"
  repository      =  var.linkerd_repository # "https://helm.linkerd.io/stable"
  chart           =  var.linkerd_chart # "linkerd-crds"
  namespace       = var.linkerd_namespace_name #"linkerd"
  # version = "1.6.1"
  create_namespace = true
}
###############################################################################
resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  is_ca_certificate     = true
  set_subject_key_id    = true
  validity_period_hours = 87600
  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
  subject {
    common_name = "root.linkerd.cluster.local"
  }
}

resource "tls_private_key" "issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "issuer" {
  private_key_pem = tls_private_key.issuer.private_key_pem
  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "issuer" {
  cert_request_pem      = tls_cert_request.issuer.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  is_ca_certificate     = true
  set_subject_key_id    = true
  validity_period_hours = 8760
  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}

resource "helm_release" "linkerd_control_plane" {
  name      = "linkerd-control-plane"
  namespace = var.linkerd_namespace_name
  chart     = var.linkerd_controlplane_chart

  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_locally_signed_cert.issuer.ca_cert_pem
  }
  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer.cert_pem
  }
  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer.private_key_pem
  }

  depends_on = [
    helm_release.linkerd_crds,
    tls_locally_signed_cert.issuer,
    tls_private_key.issuer
  ]
}

##############################################################################
# resource "null_resource" "create_ca_cert" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   provisioner "local-exec" {
#     command = "rm -f ca.crt ca.key issuer.crt issuer.key"
#     on_failure = continue  # Ensure the command runs even if the preceding command fails
#   }
#   provisioner "local-exec" {
#     command = "step certificate create root.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure"
#   }
#   provisioner "local-exec" {
#     command = "step certificate create identity.linkerd.cluster.local issuer.crt issuer.key --profile intermediate-ca --not-after 8760h --no-password --insecure --ca ca.crt --ca-key ca.key"
#   }
# }

# resource "helm_release" "linkerd_control_plane" {
#   depends_on = [null_resource.create_ca_cert, helm_release.linkerd_crds]
#   name      = "linkerd-control-plane"
#   namespace = "linkerd"
#   chart     = "linkerd/linkerd-control-plane"
#   # version = "1.12.7"
#   set {
#     name  = "identityTrustAnchorsPEM"
#     value = file("${path.module}/ca.crt")
#   }
#   set {
#     name  = "identity.issuer.tls.crtPEM"
#     value = file("${path.module}/issuer.crt")
#   }
#   set {
#     name  = "identity.issuer.tls.keyPEM"
#     value = file("${path.module}/issuer.key")
#   }
# }

# ###############################################################################
# #annotate namespace to inject linkerd sidecars
# resource "null_resource" "annotate_namespace" {
#   provisioner "local-exec" {
#     command = "kubectl annotate namespace default linkerd.io/inject=enabled"
#   }
# }

# deploy linkerd-viz
resource "helm_release" "linkerd_viz" {
  name            = "linkerd-viz"
  repository      = var.linkerd_repository # "https://helm.linkerd.io/stable"
  chart           = var.linkerd_viz_chart # "linkerd-viz"
  namespace       = var.linkerd_viz_namespace_name # "linkerd-viz"
  # version = "30.8.7"
  create_namespace = true

# FOR EXTERNAL PROMETHEUS. TO BE CONFIGURED ONCE AZURE PROMETHEUS DEPLOYED
  # set {
  #   name  = "prometheusUrl"
  #   value = "http://prometheus-server.observability.svc.cluster.local:9090"
  # }

  # set {
  #   name  = "prometheus.enabled"
  #   value = "false"
  # }
  depends_on = [helm_release.linkerd_crds, helm_release.linkerd_control_plane]
}