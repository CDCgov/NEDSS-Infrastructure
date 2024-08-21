
variable "resource_prefix" {
    type = string
    default = "dev"
}

variable "location" {
  description = "Location for Azure resources"
  type        = string
}

variable "storage_account_name" {
      type        = string
}

variable "account_tier" {
    type        = string
default = "Standard"
}       

variable "account_replication_type" {
    type = string
    default = "LRS"
} 

# variable "kafka_storage_container_name"{ 
#     type = string
# }

variable "container_access_type" {
    type = string
    default = "private"
}

variable "sg_name" {
    type = string
}

variable "kafka_cluster_name" {
    type = string
}
variable "cluster_version" {
    type = string
    default = "4.0"
}
variable "cluster_tier" {
    type = string
    default = "Standard"
}
variable "component_version" {
    type = string
    default = "2.1"
}

 variable "gtwy_username" {
    type = string
 } 

 variable "gtwy_password" {
    type = string
    sensitive   = true
 }

variable "username" {
    type = string
}
variable "password" {
    type = string
    sensitive   = true
}

variable "head_vm_size" {
    type = string
    default = "Standard_D3_V2"   
} 
variable "worker_vm_size" {
    type = string
    default = "Standard_D3_V2"   
} 
variable "zookeeper_vm_size" {
    type = string
    default = "Standard_D3_V2"  
}
variable "encryption_in_transit_enabled" {
    type = bool
    default = true
}

variable "number_of_disks_per_node" {
    type = number
    default = 1
}    

variable "target_instance_count" {
    type = number
    default = 3
}

variable "vnet_name" {
    type = string
}

variable "vnet_rg" {
    type = string
}


variable "kafka_subnet_name" {
    type = string
}

variable "tls_min_version" {
    type = string
    default = "1.2"
}

variable "destination_address_prefix" {
    type = string
    default = "VirtualNetwork"
}

variable "tags" {
  type = map(string)
  default = {
    createdby    = "Terraform"
  }
}

variable "infrastructure_encryption_enabled" {
    type = bool
    default = true
}
#############
variable "kafka_storage_account_name" {
    type = string
}

variable "kafka_storage_container_name" {
    type = string
    sensitive = true
}
###########################################
