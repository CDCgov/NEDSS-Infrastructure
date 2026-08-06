

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

variable "create_linkerd_viz" {
  description = "Whether to install linkerd viz"
  type        = bool
  default     = false
}