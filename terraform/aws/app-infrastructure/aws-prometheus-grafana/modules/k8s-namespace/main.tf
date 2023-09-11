resource "kubernetes_namespace" "example" {
  count = var.create_namespace ? 1 : 0
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = var.namespace_name
  }
}