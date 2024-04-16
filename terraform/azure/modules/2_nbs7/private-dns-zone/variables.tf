variable "resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"
  
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {}
}