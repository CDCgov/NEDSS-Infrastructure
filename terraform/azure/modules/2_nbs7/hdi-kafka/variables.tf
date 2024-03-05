# variable "create_kafka_cluster" {
#   description = "Flag to determine whether to create the Azure Event Hubs Kafka cluster"
#   type        = bool
#   default     = true # false
# }
#################################
variable "resource_prefix" {
    type = string
    default = "dev"
}

variable "location" {
  description = "Location for Azure resources"
  type        = string
  default = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default = "kafka-resources"
}

variable "storage_account_name" {
      type        = string
  default = "cselsnbsdevlowkafka" 
}

variable "account_tier" {
    type        = string
default = "Standard"
}       

variable "account_replication_type" {
    type = string
    default = "LRS"
} 

variable "kafka_storag_container_name"{ 
    type = string
    default = "kafka-hdinsight"
}

variable "container_access_type" {
    type = string
    default = "private"
}
variable "sg_name" {
    type = string
    default = "hdi-kafka-sg1"
}

variable "kafka_cluster_name" {
    type = string
    default = "hdi-kafka-cluster"
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
    default = "cdcacctestusrgw"
 } 

 variable "gtwy_password" {
    type = string
    default = "cdwTerrAform123!"
    sensitive   = true
 }

variable "username" {
    type = string
    default = "cdc-kafka-user"
}
variable "password" {
    type = string
    default = "cdcTerrAform123!"
    sensitive   = true
}

variable "head_vm_size" {
    type = string
    default = "Standard_D3_V2"   #D2a v4  # "Standard_D3_V2" 
} 
variable "worker_vm_size" {
    type = string
    default = "Standard_D3_V2"   #D2a v4  # "Standard_D3_V2" 
} 
variable "zookeeper_vm_size" {
    type = string
    default = "Standard_D3_V2"   #D2a v4  # "Standard_D3_V2" 
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
    default = "csels-nbs-dev-low-modern-app-vnet"
}

variable "vnet_rg" {
    type = string
    default = "csels-nbs-dev-low-rg"
}


variable "kafka_subnet_name" {
    type = string
    default = "csels-nbs-dev-low-hdi-kafka-vnet-sn"
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
###########################################
