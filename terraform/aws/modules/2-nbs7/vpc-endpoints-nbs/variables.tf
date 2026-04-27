variable "vpc_id" {
  description = "The ID of your provisioned VPC."
  type        = string
}
variable "vpc_cidr_block" {
  description = "CIDR block of your VPC."
  type        = string
}
variable "private_subnet_ids" {
  description = "Private VPC subnet IDs to associate with vpc endpoints."
  type        = list(any)
}
variable "tags" {
  description = "Tags to associate with created resources."
  type        = map(string)
}
variable "create_prometheus_vpc_endpoint" {
  description = "Create Prometheus VPC endpoint and security group?"
  type        = bool
  default     = true
}
variable "create_grafana_vpc_endpoint" {
  description = "Create Grafana VPC endpoint and security group?"
  type        = bool
  default     = true
}
variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}