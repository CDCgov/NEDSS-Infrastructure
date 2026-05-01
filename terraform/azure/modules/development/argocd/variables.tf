variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "cdc-nbs"
}

variable "deploy_argocd_helm" {
  description = "Do you wish to bootstrap ArgoCD with the EKS cluster deployment?"
  type        = string
  default     = "false"
}

variable "argocd_version" {
  description = "Version of ArgoCD with which to bootstrap EKS cluster"
  type        = string
  default     = "5.27.1"
}