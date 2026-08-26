variable "linkerd_repository" {
  description = "Repository to use when installing linkerd"
  type        = string
  default     = "https://helm.linkerd.io/stable"
}

variable "linkerd_chart" {
  description = "Name of linkerd chart"
  type        = string
  default     = "linkerd-crds"
}

variable "linkerd_namespace_name" {
  description = "Name of linkerd namespace"
  type        = string
  default     = "linkerd"
}

variable "linkerd_controlplane_chart" {
  description = "Name of linkerd control plane chart"
  type        = string
  default     = "linkerd-control-plane"
}

variable "linkerd_viz_chart" {
  description = "Name of linkerd viz chart"
  type        = string
  default     = "linkerd-viz"
}

variable "linkerd_viz_namespace_name" {
  description = "Name of linkerd viz namespace"
  type        = string
  default     = "linkerd-viz"
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
  description = "Base64-encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "linkerd_helm_version" {
  description = "linkerd edge helm version"
  type        = string
  default     = "2025.7.3"
}