variable "bucket_name" {}
variable "tags" {
  type = map(string)
}

variable "force_destroy_log_bucket" {
  type = string
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error."
  default = false
}