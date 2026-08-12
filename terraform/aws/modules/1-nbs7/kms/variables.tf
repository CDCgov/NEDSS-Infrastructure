variable "description" {
  description = "Give your key a description."
  type        = string
}

variable "deletion_window_in_days" {
  description = "Number of days to wait before deleting a KMS key range: 7-30"
  type        = number
  default     = 7
}

variable "key_usage" {
  description = "The intended use of the key"
  type        = string
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition = contains(
      ["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"],
      var.key_usage
    )
    error_message = "ERROR: key_usage is not valid, must be one of ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }
}

variable "aliases" {
  description = "The list of aliases to give the key"
  type        = list(string)
}

variable "enable_key_rotation" {
  description = "Set to true to enable automatic key rotation"
  type        = bool
  default     = true
}

variable "key_administrators" {
  description = "A list of IAM ARNs for key administrators"
  type        = list(any)
  default     = []
}

variable "key_users" {
  description = "A list of IAM ARNs for key users"
  type        = list(any)
  default     = []
}

variable "key_service_users" {
  description = "A list of IAM ARNs for key service users"
  type        = list(any)
  default     = []
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`)"
  type        = bool
  default     = false
}

# Values to modify for custom policies
variable "key_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = list(any)
  default     = []
}
