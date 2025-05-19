variable "log_group_name" { default = "fluent-bit-cloudwatch"}

variable "app_name" {
  type    = list(string)
  default = ["argocd", "elasticsearch", "fluentbit", "ingress-nginx", "nifi", "prometheus", "modernization-api", "dataingestion-service", "data-processing-service", "debezium-service-connect", "investigation-reporting-service", "kafka-rtr-sink-connector-cp-kafka-connect", "keycloak-deployment", "ldfdata-reporting-service", "liquibase-service", "nnd-service", "observation-reporting-service", "organization-reporting-service", "page-builder-api", "person-reporting-service", "post-processing-reporting-service" ]
}

variable "resource_prefix" {}