variable "enabled" {
  type        = bool
  description = "Whether to have Terraform provision the resources from this module in your Azure subscription"
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = ""
  validation { # The condition must evaluate to true for the validation to pass
    condition     = (!var.enabled) || (var.enabled && var.resource_group_name != "")
    error_message = "resource_group_name must have a value if module is enabled"
  }
}

variable "public_domain_name" {
  type        = string
  description = "The root domain (e.g., example.com)"
  default     = ""
  validation {
    condition     = (!var.enabled) || (var.enabled && var.public_domain_name != "")
    error_message = "public_domain_name must have a value if module is enabled"
  }
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