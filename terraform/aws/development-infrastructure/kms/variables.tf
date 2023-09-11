variable "description" {
  type        = string
  description = "Give your key a description."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "Number of days to wait before deleting a KMS key range: 7-30"
}

variable "key_usage" {
  default = "ENCRYPT_DECRYPT"
  type    = string
  validation {
    condition = contains(
      ["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"],
      var.key_usage
    )
    error_message = "ERROR: key_usage is not valid, must be one of ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }
}

variable "aliases" {
  type = list(string)
}

variable "enable_key_rotation" {
  default = true
  type    = bool
}

variable "key_administrators" {
  type        = list(any)
  default     = []
  description = "A list of IAM ARNs for key administrators"
}
variable "key_users" {
  type        = list(any)
  default     = []
  description = "A list of IAM ARNs for key users"
}
variable "key_service_users" {
  type        = list(any)
  default     = []
  description = "A list of IAM ARNs for key service users"
}

variable "multi_region" {
  default     = false
  description = " Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`)"
}

# Values to modify for custom policies
variable "key_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = {}
}
