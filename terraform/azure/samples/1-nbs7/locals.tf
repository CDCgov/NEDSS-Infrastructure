locals {
  aks_resource_prefix           = var.aks_resource_prefix != "" ? var.aks_resource_prefix : var.environment_name
  kafka_resource_prefix         = var.kafka_resource_prefix != "" ? var.kafka_resource_prefix : var.environment_name
  observability_resource_prefix = var.observability_resource_prefix != "" ? var.observability_resource_prefix : var.environment_name
}