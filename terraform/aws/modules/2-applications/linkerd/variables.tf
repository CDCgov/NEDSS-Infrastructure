variable "linkerd_repository" {
  description = "Repository to use when installing linkerd"
  type        = string
  default     = "https://helm.linkerd.io/stable"
}

variable "linkerd_namespace_name" {
  description = "Name of linkerd namespace"
  type        = string
  default     = "linkerd"
}

variable "linkerd_crds_chart" {
  description = "Name of linkerd crds chart"
  type        = string
  default     = "linkerd-crds"
}

variable "linkerd_crds_chart_version" {
  description = "Version of linkerd crds chart"
  type        = string
  default     = "1.8.0"
}

variable "linkerd_controlplane_chart" {
  description = "Name of linkerd control plane chart"
  type        = string
  default     = "linkerd-control-plane"
}

variable "linkerd_controlplane_chart_version" {
  description = "Version of linkerd control plane chart"
  type        = string
  default     = "1.16.11"
}

variable "linkerd_viz_chart" {
  description = "Name of linkerd viz chart"
  type        = string
  default     = "linkerd-viz"
}

variable "linkerd_viz_chart_version" {
  description = "Version of linkerd viz chart"
  type        = string
  default     = "30.12.11"
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
  description = "The hostname (in form of URI) of the Kubernetes API."
  type        = string
  # The endpoint can be retrieved via: `aws eks describe-cluster --name <cluster-name> --query "cluster.endpoint" --output text`
  # Reference info: https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html
}

variable "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data required to communicate with the cluster"
  type        = string
}
