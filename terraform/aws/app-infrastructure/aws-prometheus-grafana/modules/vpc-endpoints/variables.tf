variable "vpc_id" {}
variable "prometheus_sg_name" {}
variable "vpc_cidr_block" {}
variable "private_subnet_ids" { type = list}
variable "region" {}
variable "grafana_sg_name" {}
variable "tags" {}
variable "prometheus_endpoint" {}
variable "grafana_endpoint" {}