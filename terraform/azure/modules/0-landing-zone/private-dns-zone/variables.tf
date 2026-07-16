variable "enabled" {
  type        = bool
  description = "Whether to have Terraform provision the resources from this module in your Azure subscription"
  default     = true
}

# Note that if "enabled" is true then a non-empty value must be specified for "resource_group_name" and also for "private_dns_zone_name", otherwise `terraform plan` will fail (because those variables are used by resources for args which do not allow an empty string).

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = ""
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name for the private dns zone"
  default     = ""
}

variable "vnet_id" {
  type        = string
  description = "vnet id"
}

variable "vnet_name" {
  type        = string
  description = "vnet name"
}

variable "dns_records" {
  description = "A map of DNS records to create"
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