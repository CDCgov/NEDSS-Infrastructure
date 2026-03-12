# Priority class to ensure Linkerd components are scheduled before application pods
# This addresses DEV-27: Linkerd scheduling requirements to prevent service mesh injection issues

resource "kubernetes_priority_class" "linkerd_critical" {
  metadata {
    name = "linkerd-critical"
  }

  value          = 1000000
  description    = "Priority class for Linkerd service mesh components to ensure they start before application pods during cluster scale operations"
  global_default = false
}