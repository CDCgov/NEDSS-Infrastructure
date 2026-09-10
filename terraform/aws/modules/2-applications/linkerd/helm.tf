# Deploys linkerd, linkerd control plane and linkerd visualization dashboard

locals {
  # The edge release channel (i.e. https://artifacthub.io/packages/helm/linkerd2-edge/linkerd-crds) is the only viable open source option of a repository for this chart. 
  # (The Linkerd open-source project stopped publishing official open-source stable release (i.e. https://artifacthub.io/packages/helm/linkerd2/linkerd-crds) Helm charts and artifacts starting with Linkerd 2.15 in 2024.)
  linkerd_repository = var.linkerd_repository != null ? var.linkerd_repository : "https://helm.linkerd.io/edge"

  # The edge release channel (per https://linkerd.io/releases/) publishes new chart versions weekly which are production ready,
  # so here we should not pin/specify any value for the 'version' arg on this resource.
  # (With the edge release channel, the same given version number is published for all the linkerd charts.)
  linkerd_charts_version = var.linkerd_helm_version != null ? var.linkerd_helm_version : null
}

# Reference info: https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "linkerd_crds" {
  name             = "linkerd-crds"
  repository       = local.linkerd_repository
  chart            = var.linkerd_chart != null ? var.linkerd_chart : "linkerd-crds"
  namespace        = var.linkerd_namespace_name
  create_namespace = true
  version          = local.linkerd_charts_version
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

resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = local.linkerd_repository
  namespace  = var.linkerd_namespace_name
  chart      = var.linkerd_controlplane_chart != null ? var.linkerd_controlplane_chart : "linkerd-control-plane"
  version    = local.linkerd_charts_version

  set = [
    {
      name  = "identityTrustAnchorsPEM"
      value = tls_locally_signed_cert.issuer.ca_cert_pem
    },
    {
      name  = "identity.issuer.tls.crtPEM"
      value = tls_locally_signed_cert.issuer.cert_pem
    },
    {
      name  = "identity.issuer.tls.keyPEM"
      value = tls_private_key.issuer.private_key_pem
    }
  ]

  depends_on = [
    helm_release.linkerd_crds
  ]
}

resource "helm_release" "linkerd_viz" {
  count = var.deploy_linkerd_viz ? 1 : 0

  name             = "linkerd-viz"
  repository       = local.linkerd_repository
  chart            = var.linkerd_viz_chart != null ? var.linkerd_viz_chart : "linkerd-viz"
  namespace        = var.linkerd_viz_namespace_name
  create_namespace = true
  version          = local.linkerd_charts_version
  depends_on       = [helm_release.linkerd_crds, helm_release.linkerd_control_plane]
}
