variable "aws_role_arn" {
  description = "AWS Role arn used to authenticate into EKS cluster"
  type        = string
}

variable "resource_prefix" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id to be used with cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet Ids to be used when creating EKS cluster"
  type        = list(any)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "eks_disk_size" {
  description = "Size of EKS volumes in GB"
  type        = number
  default     = 20
}

variable "eks_instance_types" {
  description = "Instance type to use in EKS cluster"
  type        = list(any)
  default     = ["m5.large"]
}

variable "eks_desired_nodes_count" {
  description = "Number of EKS nodes desired (defaul = 2)"
  type        = number
  default     = 2
}

variable "eks_max_nodes_count" {
  description = "Maximum number of EKS nodes (defaul = 5)"
  type        = number
  default     = 5
}

variable "eks_min_nodes_count" {
  description = "Number of EKS nodes desired (defaul = 1)"
  type        = number
  default     = 1
}

variable "eks_cluster_version" {
  description = "Version of EKS cluster to provision"
  type        = string
  default     = "1.24"
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.15.0-eksbuild.1"
    }
  ]
}

variable "argocd_version" {
  description = "Version of ArgoCD with which to bootstrap EKS cluster"
  type        = string
  default     = "5.23.3"
}

variable "argocd_imageupdater_version" {
  description = "Version of ArgoCDImageUpdater with which to bootstrap EKS cluster"
  type        = string
  default     = "0.8.4"
}

variable "ebs_delete_volume_on_termination" {
  description = "Delete EBS volume on termination"
  type        = bool
  default     = true
}

variable "ebs_encrypted" {
  description = "Encrypt EBS volume on creation"
  type        = bool
  default     = true
}

variable "ebs_volume_size" {
  description = "EBS volume size on creation"
  type        = number
  default     = 100
}

variable "ebs_volume_type" {
  description = "EBS volume type on creation"
  type        = string
  default     = "gp3"
}
