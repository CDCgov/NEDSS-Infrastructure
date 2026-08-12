variable "enabled" {
  description = "Whether to have Terraform provision the resources from this module in your Azure subscription"
  type        = bool
  default     = true # If this is false then all the other variables below are ignored
}

# Note that if "enabled" is true then a non-empty value must be specified for "resource_group_name" and also for "private_dns_zone_name", otherwise `terraform plan` will fail (because those variables are used by resources for args which do not allow an empty string).

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = ""
}

variable "private_dns_zone_name" {
  description = "Name for the private dns zone"
  type        = string
  default     = ""
}

variable "vnet_id" {
  description = "vnet id"
  type        = string
}

variable "vnet_name" {
  description = "vnet name"
  type        = string
}

variable "dns_records" {
  description = "A map of DNS records to create in the private dns zone. Only provide this if the 'enabled' variable is set to true."
  type = map(object({
    record_name  = string
    record_type  = string
    ttl          = optional(number, 300)
    records      = optional(list(string))
    cname_record = optional(string)
  }))
  default = {}
}

variable "registration_enabled" {
  description = "Whether auto registration is enabled"
  type        = bool
  default     = false
}
