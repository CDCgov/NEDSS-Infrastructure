variable "bucket_prefix" {
  type        = string
  description = "Bucket name prefix (result is guaranteed to be unique)."
  default     = "cdc-nbs"
}
variable "enable_default_bucket_lifecycle_policy" {
  type        = string
  description = "Whether the default rule is currently being applied. Valid values: Enabled or Disabled."
  default     = "Disabled"
  validation {
    condition     = var.enable_default_bucket_lifecycle_policy == "Enabled" || var.enable_default_bucket_lifecycle_policy == "Disabled"
    error_message = "enable_default_bucket_lifecycle_policy for the s3-bucket module must either \"Enabled\" or \"Disabled\""
  }
}

variable "mark_object_for_delete_days" {
  type        = number
  description = "Number of days until a new objects is marked noncurrent (gets a delete marker)."
  default     = 30
}

variable "delete_noncurrent_objects" {
  type        = number
  description = "Number of days until a noncurrent object is PERMANENTLY deleted (total days before object deletion is calculated by mark_object_for_delete_days + delete_noncurrent_objects)."
  default     = 60
}

variable "tags" {
  description = "Tags to associate with created resources."
  type        = map(string)
}

variable "force_destroy_bucket" {
  type        = bool
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error."
  default     = false
}
