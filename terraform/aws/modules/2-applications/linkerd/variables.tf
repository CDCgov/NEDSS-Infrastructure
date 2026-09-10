# In a future release the deprecated variables below will be removed.

############  linkerd miscellaneous variables: ############

variable "linkerd_repository" {
  description = "(DEPRECATED) Repository to use when installing linkerd"
  type        = string
  default     = null
  deprecated  = "Nowadays https://helm.linkerd.io/edge is the only open source option of a repository for the Linkerd Helm charts."
}

variable "linkerd_namespace_name" {
  description = "Name of linkerd namespace"
  type        = string
  default     = "linkerd"
}

variable "linkerd_helm_version" {
  description = "(DEPRECATED) Version of linkerd charts"
  type        = string
  default     = null
  deprecated  = "There are new production ready versions of these charts released weekly, so there is no need (nor would it be practical) to specify a version of the charts to use."
}

############ linkerd crds variable: ############

variable "linkerd_chart" {
  description = "(DEPRECATED) Name of linkerd crds chart"
  type        = string
  default     = null
  deprecated  = "Per https://linkerd.io/docs/tasks/install-helm/ there is only one name/option for this chart."
}

############ linkerd controlplane variables: ############

variable "linkerd_controlplane_chart" {
  description = "(DEPRECATED) Name of linkerd control plane chart"
  type        = string
  default     = null
  deprecated  = "Per https://linkerd.io/docs/tasks/install-helm/ there is only one name/option for this chart."
}

############ linkerd viz variables: ############

variable "deploy_linkerd_viz" {
  description = "Whether to deploy the linkerd viz chart"
  type        = bool
  default     = false
}

variable "linkerd_viz_chart" {
  description = "(DEPRECATED) Name of linkerd viz chart"
  type        = string
  default     = null
  deprecated  = "Per https://linkerd.io/docs/tasks/install-helm/ there is only one name/option for this chart."
}

variable "linkerd_viz_namespace_name" {
  description = "Name of linkerd viz namespace"
  type        = string
  default     = "linkerd-viz"
}

############ eks variables: ############

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
