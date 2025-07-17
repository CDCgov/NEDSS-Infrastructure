
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
  type = string
  description = "Name of the EKS cluster"
} 

variable "eks_cluster_endpoint" {
  type = string
  description = "Name of the EKS cluster"  
}

variable "cluster_certificate_authority_data" {
  type = string
  description = "TBase64 encoded certificate data required to communicate with the cluster"
}

variable "version" {
  type = string
  default = "2025.7.3"
  description = "linkerd edge helm version"  
}