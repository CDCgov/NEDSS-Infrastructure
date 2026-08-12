variable "bucket_prefix" {
  description = "Bucket name prefix (result is guaranteed to be unique)."
  type        = string
  default     = "cdc-nbs"
}
variable "enable_default_bucket_lifecycle_policy" {
  description = "Whether the default rule is currently being applied. Valid values: Enabled or Disabled."
  type        = string
  default     = "Disabled"
  validation {
    condition     = var.enable_default_bucket_lifecycle_policy == "Enabled" || var.enable_default_bucket_lifecycle_policy == "Disabled"
    error_message = "enable_default_bucket_lifecycle_policy for the s3-bucket module must either \"Enabled\" or \"Disabled\""
  }
}

variable "mark_object_for_delete_days" {
  description = "Number of days until a new objects is marked noncurrent (gets a delete marker)."
  type        = number
  default     = 30
}

variable "delete_noncurrent_objects" {
  description = "Number of days until a noncurrent object is PERMANENTLY deleted (total days before object deletion is calculated by mark_object_for_delete_days + delete_noncurrent_objects)."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to associate with created resources."
  type        = map(string)
}

variable "force_destroy_bucket" {
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error."
  type        = bool
  default     = false
}
