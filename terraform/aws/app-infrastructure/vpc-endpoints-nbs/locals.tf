locals {
  grafana_sg_name     = "${var.resource_prefix}-amg-sg"
  grafana_endpoint    = "${var.resource_prefix}-amg-endpoint-sg"
  prometheus_sg_name  = "${var.resource_prefix}-amp-sg"
  prometheus_endpoint = "${var.resource_prefix}-amp-endpoint-sg"
}
