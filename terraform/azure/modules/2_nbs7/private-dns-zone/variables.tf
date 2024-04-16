variable "resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"
  
}

variable "ignore_changes" {
  description = "A list of changes to ignore in all resources"
  type        = list(any)
  default = []
}