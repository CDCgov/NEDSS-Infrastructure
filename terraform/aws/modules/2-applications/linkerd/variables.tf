
variable "linkerd_repository" {
  default = "https://helm.linkerd.io/edge"
}

variable "linkerd_chart" {
  default = "linkerd-crds"
}

variable "linkerd_namespace_name" {
  default = "linkerd"
}

variable "linkerd_controlplane_chart" {
  default = "linkerd-control-plane"
}

variable "linkerd_viz_chart" {
  default = "linkerd-viz"
}

variable "linkerd_viz_namespace_name" {
  default = "linkerd-viz"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "TBase64 encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "linkerd_helm_version" {
  description = "linkerd edge helm version"
  type        = string
  default     = "2025.7.3"
}