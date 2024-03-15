
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
    default = "linkerd/linkerd-control-plane"
}
variable "linkerd_viz_chart" {
    default = "linkerd-viz"
}
variable "linkerd_viz_namespace_name" {
    default = "linkerd-viz"
}

variable "resource_group_name" {
    type = string
    default = "csels-nbs-dev-low-rg"
}
#### GENERAL
# variable "cluster_certificate_authority_data" {
#   type = string
#   description = "TBase64 encoded certificate data required to communicate with the cluster"
# }

# variable "eks_cluster_endpoint" {
#   type = string
#   description = "The endpoint of the EKS cluster"
# } 

# variable "eks_cluster_name" {
#   type = string
#   description = "Name of the EKS cluster"
# } 

# variable "eks_aws_role_arn" {
#   type = string
#   description = "IAM role ARN of the EKS cluster"
# }