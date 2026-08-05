variable "resource_group_name" {
  description = "Resource group name for existing and to be deployed azure resources"
  type        = string
}

variable "virtual_network_name" {
  description = "List of virtual network names to be associated as a virtual network link for the private dns zone."
  type        = list(string)
  default     = []
}