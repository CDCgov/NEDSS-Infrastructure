variable "storage_account_name" {
  type        = string
  description = "Name for storage account. (Names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only)"
  default     = "nbsstorageaccount"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for existing and to be deployed azure resources"
  
}

variable "account_kind" {
  type        = string
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default = "StorageV2"
  
}

variable "account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  default = "Standard"
  
}

variable "create_dns_record" {
  type        = bool
  description = "Create a DNS entry in an existing DNS zone?"
  default = false
}

variable "blob_private_ip_address" {
  type        = string
  description = "Private IP address to set for storage account file endpoint. (leave null to auto assign)"  
  default = null
}

variable "file_private_ip_address" {
  type        = string
  description = "Private IP address to set for storage account file endpoint. (leave null to auto assign)"  
  default = null
}

# For definitions see https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy
variable "account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa."
  default = "GRS"
  
}

variable "subnet_name" {
  type = string
  description = "Name of subnet within virtual_network_name to be associated with storage account private endpoints."
}

variable "virtual_network_name" {
  type = string
  description = "Name of virtual network to be associated with storage account private endpoints."
}

variable "infrastructure_encryption_enabled" {
  type = bool
  description = "Is infrastructure encryption enabled?"
  default = true
}

# Network
variable "public_network_access_enabled" {
  type = bool
  description = "Whether the public network access is enabled?"
  default = false
}

variable "dns_zone_id_blob" {
  type = string
  description = "Zone id of DNS to which record will be added for blob storage.(create_dns_record must be true)"
  default = ""
}

variable "dns_zone_name_blob" {
  type = string
  description = "Name of DNS zone to which record will be added for blob storage. (create_dns_record must be true)"
  default = ""
}

variable "dns_zone_id_file" {
  type = string
  description = "Zone id of DNS to which record will be added for file storage. (create_dns_record must be true)"
  default = ""
}

variable "dns_zone_name_file" {
  type = string
  description = "Name of DNS zone to which record will be added for file storage. (create_dns_record must be true)"
  default = ""
}

# Data retention
variable "blob_delete_retention_days" {
  type = number
  description = "Number of days to retain soft deleted blobs. Default 7 days."
  default = 7
}

variable "blob_container_delete_retention_days" {
  type = number
  description = "Number of days to retain soft delete containers. Default 7 days."
  default = 7
}