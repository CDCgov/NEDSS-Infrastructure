
variable "linkerd_repository" {
  description = "Linkerd repository url"
  type        = string
  default = "https://helm.linkerd.io/edge"
}

variable "linkerd_chart" {
  description = "Name of the linkerd chart"
  type        = string
  default = "linkerd-crds"
}

variable "linkerd_namespace_name" {
  description = "Name for the linkerd namespace"
  type        = string
  default = "linkerd"
}

variable "linkerd_controlplane_chart" {
  description = "Name of the linkerd control plane chart"
  type        = string
  default = "linkerd-control-plane"
}

variable "linkerd_viz_chart" {
  description = "Name of the linkerd-viz chart"
  type        = string
  default = "linkerd-viz"
}

variable "linkerd_viz_namespace_name" {
  description = "Name for the linkerd-viz namespace"
  type        = string
  default = "linkerd-viz"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "linkerd_helm_version" {
  description = "linkerd edge helm version"
  type        = string
  default     = "2025.7.3"
}