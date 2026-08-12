variable "namespace_name" {
  description = "The name of the Kubernetes namespace"
  type        = string
}

variable "create_namespace" {
  description = "Set to true to create the namespace"
  type        = bool
}