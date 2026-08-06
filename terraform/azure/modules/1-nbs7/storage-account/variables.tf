variable "storage_account_name" {
  description = "Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only)"
  type        = string
  default     = "nbsstorageaccount"
}

variable "resource_group_name" {
  description = "Resource group name for existing and to be deployed azure resources"
  type        = string

}

variable "account_kind" {
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  type        = string
  default     = "StorageV2"

}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"

}

variable "create_dns_record" {
  description = "Create a DNS entry in an existing DNS zone? False requires manual addition of DNS configuration for private endpoint."
  type        = bool
  default     = false
}

variable "blob_private_ip_address" {
  description = "Private IP address to set for storage account file endpoint. (leave null to auto assign)"
  type        = string
  default     = null
}

variable "file_private_ip_address" {
  description = "Private IP address to set for storage account file endpoint. (leave null to auto assign)"
  type        = string
  default     = null
}

# For definitions see https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy
variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa."
  type        = string
  default     = "GRS"

}

variable "subnet_name" {
  description = "Name of subnet within virtual_network_name to be associated with storage account private endpoints."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of virtual network to be associated with storage account private endpoints."
  type        = string
}

# Network
variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled?"
  type        = bool
  default     = false
}

variable "dns_zone_id_blob" {
  description = "Zone id of DNS to which record will be added for blob storage.(create_dns_record must be true)"
  type        = string
  default     = ""
}

variable "dns_zone_id_file" {
  description = "Zone id of DNS to which record will be added for file storage. (create_dns_record must be true)"
  type        = string
  default     = ""
}

# Data retention
variable "blob_delete_retention_days" {
  description = "Number of days to retain soft deleted blobs. Default 7 days."
  type        = number
  default     = 7
}

variable "blob_container_delete_retention_days" {
  description = "Number of days to retain soft delete containers. Default 7 days."
  type        = number
  default     = 7
}