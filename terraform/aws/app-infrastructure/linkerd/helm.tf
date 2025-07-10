# Deploys linkerd, linkerd control plane and linkerd visualization dashboard
# #############################################################
# linkerd helm release
resource "helm_release" "linkerd_crds" {
  name            = "linkerd-crds"
  repository      =  var.linkerd_repository # "https://helm.linkerd.io/stable"
  chart           =  var.linkerd_chart # "linkerd-crds"
  namespace       = var.linkerd_namespace_name #"linkerd"
  create_namespace = true
  version    = "1.8.0"  # Matches Linkerd 2.18.0
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
  name       = "linkerd-control-plane"
  repository      =  var.linkerd_repository # "https://helm.linkerd.io/stable"
  namespace = var.linkerd_namespace_name 
  chart     = var.linkerd_controlplane_chart  #"linkerd-control-plane"
  version    = "1.15.0"  # This version maps to Linkerd 2.18.0

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


# deploy linkerd-viz
resource "helm_release" "linkerd_viz" {
  name            = "linkerd-viz"
  repository      = var.linkerd_repository # "https://helm.linkerd.io/stable"
  chart           = var.linkerd_viz_chart 
  namespace       = var.linkerd_viz_namespace_name 
  create_namespace = true
  depends_on = [helm_release.linkerd_crds, helm_release.linkerd_control_plane]
  version    = "30.10.0"  # For Linkerd 2.18.0
}
