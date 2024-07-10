
variable "aks_cluster_name" {
type = string
default = "dev-aks" 
}

variable "linkerd_repository" {
    default = "https://helm.linkerd.io/stable"
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

variable "resource_group_name" {
    type = string
}