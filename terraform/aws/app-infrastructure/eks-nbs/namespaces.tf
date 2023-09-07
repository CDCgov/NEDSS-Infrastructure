resource "kubernetes_namespace" "observability" {  
  provider         = kubernetes
  metadata {
    labels = var.observability_labels
    name = var.observability_namespace
  }  
}