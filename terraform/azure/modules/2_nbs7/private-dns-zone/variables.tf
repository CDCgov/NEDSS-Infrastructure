variable "resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"
}

variable "virtual_network_name" {
  type        = list(string)
  description = "StringList of virtual network names to be associated as a virtual network link for the private dns zone."
  default     = []
}