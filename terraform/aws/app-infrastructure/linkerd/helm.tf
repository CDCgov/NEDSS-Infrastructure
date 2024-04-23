# Deploys linkerd, linkerd control plane and linkerd visualization dashboard
# #############################################################
# data "aws_eks_cluster_auth" "cluster" {
#   name = "cdc-nbs-fts1-eks"
# }

# data "aws_eks_cluster" "eks_cluster" {
#   name = "cdc-nbs-fts1-eks"
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.eks_cluster.endpoint                              # module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data) # base64decode(var.cluster_certificate_authority_data) # base64decode(module.eks.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks_cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data) # base64decode(var.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# linkerd helm release
resource "helm_release" "linkerd_crds" {
  name            = "linkerd-crds"
  repository      =  var.linkerd_repository # "https://helm.linkerd.io/stable"
  chart           =  var.linkerd_chart # "linkerd-crds"
  namespace       = var.linkerd_namespace_name #"linkerd"
  create_namespace = true
}

# linkerd self-signed certs
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

# linkerd control plane
resource "helm_release" "linkerd_control_plane" {
  name      = "linkerd-control-plane"
  namespace = var.linkerd_namespace_name 
  chart     = var.linkerd_controlplane_chart  #"linkerd/linkerd-control-plane"

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
    helm_release.linkerd_crds
  ]
}

# annotate namespace to inject linkerd sidecars
resource "null_resource" "annotate_namespace" {
  provisioner "local-exec" {
    command = "kubectl annotate namespace default linkerd.io/inject=enabled"
  }
}

# deploy linkerd-viz
resource "helm_release" "linkerd_viz" {
  name            = "linkerd-viz"
  repository      = var.linkerd_repository # "https://helm.linkerd.io/stable"
  chart           = var.linkerd_viz_chart 
  namespace       = var.linkerd_viz_namespace_name 
  create_namespace = true
  depends_on = [helm_release.linkerd_crds, helm_release.linkerd_control_plane]
}
