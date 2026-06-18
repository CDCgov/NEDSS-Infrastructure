variable "enabled" {
  type        = bool
  description = "Whether to enable the module"
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
