variable "log_group_name" { default = "fluent-bit-cloudwatch" }

variable "app_name" {
  type    = list(string)
  default = ["argocd", "elasticsearch", "fluentbit", "ingress-nginx", "istio", "nifi", "patient-search", "prometheus", "modernization-api", "dataingestion"]
}

variable "resource_prefix" {}