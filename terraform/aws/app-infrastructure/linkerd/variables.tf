
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
    default = "linkerd/linkerd-control-plane"
}
variable "linkerd_viz_chart" {
    default = "linkerd-viz"
}
variable "linkerd_viz_namespace_name" {
    default = "linkerd-viz"
}

#### GENERAL
variable "eks_cluster_endpoint" {}
variable "cluster_certificate_authority_data" {}
variable "target_account_id" {}
variable "eks_cluster_name" {}