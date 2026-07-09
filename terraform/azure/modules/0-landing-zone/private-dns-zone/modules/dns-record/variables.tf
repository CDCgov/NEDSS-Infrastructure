variable "resource_group_name" {
  description = "The name of the resource group where the Private DNS zone exists."
  type        = string
}

variable "zone_name" {
  description = "The name of the private DNS zone (e.g., 'privatelink.database.windows.net')."
  type        = string
}

variable "record_name" {
  description = "The name of the private DNS record."
  type        = string
}

variable "record_type" {
  description = "The type of record to create. Must be either 'A' or 'CNAME'."
  type        = string
  validation {
    condition     = contains(["A", "CNAME"], upper(var.record_type))
    error_message = "The record_type must be either 'A' or 'CNAME'."
  }
}

variable "ttl" {
  description = "The Time To Live (TTL) of the DNS record in seconds."
  type        = number
  default     = 3600
}

variable "records" {
  description = "A list of IPv4 addresses. Required if record_type is 'A'."
  type        = list(string)
  default     = null
}

variable "cname_record" {
  description = "The target domain name. Required if record_type is 'CNAME'."
  type        = string
  default     = null
}