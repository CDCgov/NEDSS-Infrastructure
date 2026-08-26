variable "enabled" {
  description = "Enable the module"
  type        = bool
  default     = true
}

variable "resource_prefix" {
  description = "Prefix for all Kafka resources"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region to use for the resources"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account to use with Kafka"
  type        = string
}

variable "account_tier" {
  description = "The performance tier of the storage account"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication type of the storage account"
  type        = string
  default     = "LRS"
}

# variable "kafka_storage_container_name" {
#   description = "The name of the storage container"
#   type        = string
# }

variable "container_access_type" {
  description = "The access type of the storage container"
  type        = string
  default     = "private"
}

variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "kafka_cluster_name" {
  description = "The name of the Kafka cluster"
  type        = string
}

variable "cluster_version" {
  description = "The version of the HDInsight cluster"
  type        = string
  default     = "5.1"
}

variable "cluster_tier" {
  description = "The tier of the HDInsight cluster"
  type        = string
  default     = "Standard"
}

variable "component_version" {
  description = "The version of the Kafka component"
  type        = string
  default     = "3.2"
}

variable "gtwy_username" {
  description = "The username for the Ambari gateway"
  type        = string
}

variable "gtwy_password" {
  description = "The password for the Ambari gateway"
  type        = string
  sensitive   = true
}

variable "username" {
  description = "The username for the Kafka cluster login"
  type        = string
}

variable "password" {
  description = "The password for the Kafka cluster login"
  type        = string
  sensitive   = true
}

variable "head_vm_size" {
  description = "The VM size of the head node"
  type        = string
  default     = "Standard_D3_V2"
}

variable "worker_vm_size" {
  description = "The VM size of the worker node"
  type        = string
  default     = "Standard_D3_V2"
}

variable "zookeeper_vm_size" {
  description = "The VM size of the zookeeper node"
  type        = string
  default     = "Standard_D3_V2"
}

variable "encryption_in_transit_enabled" {
  description = "Set to true to enable encryption in transit"
  type        = bool
  default     = true
}

variable "number_of_disks_per_node" {
  description = "The number of disks to attach to each worker node"
  type        = number
  default     = 1
}

variable "target_instance_count" {
  description = "The target number of worker node instances"
  type        = number
  default     = 3
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_rg" {
  description = "The name of the resource group that holds the virtual network"
  type        = string
}

variable "kafka_subnet_name" {
  description = "The name of the Kafka subnet"
  type        = string
}

variable "tls_min_version" {
  description = "The minimum TLS version to allow"
  type        = string
  default     = "1.2"
}

variable "destination_address_prefix" {
  description = "The destination address prefix for the network security rule"
  type        = string
  default     = "VirtualNetwork"
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
  default = {
    createdby = "Terraform"
  }
}

variable "infrastructure_encryption_enabled" {
  description = "Set to true to enable infrastructure encryption"
  type        = bool
  default     = true
}
variable "nat_gateway_enabled" {
  description = "Enable NAT gateway to allow VM helath checks to reach the management api"
  type        = bool
  default     = true
}