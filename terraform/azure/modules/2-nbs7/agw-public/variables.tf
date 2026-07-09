variable "enabled" {
  description = <<EOT
  Whether to have Terraform provision the resources from this module 
  in your Azure subscription
  EOT
  type        = bool
  default     = true
}

variable "resource_prefix" {
  description = "Prefix used for naming module resources"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.resource_prefix))
    error_message = <<EOT
    The resource_prefix must contain only alphanumeric characters and hyphens
    EOT
  }
}

variable "agw_resource_group_name" {
  description = "The name of the Application Gateway resource group"
  type        = string
}

variable "agw_vnet_name" {
  description = <<EOT
  The name of the Azure Virtual Network (VNet) containing the 
  Application Gateway subnet.
  EOT
  type        = string
}

variable "agw_subnet_name" {
  description = "Subnet for Application Gateway deployment"
  type        = string
}

variable "agw_key_vault_name" {
  description = <<EOT
  Name of Existing Key Vault containing public/private 
  certificates stored as secrets
  EOT
  type        = string
}

variable "agw_key_vault_cert_rg" {
  description = "Key Vault Certificate Resource Group"
  type        = string
}

variable "agw_key_vault_cert_name_public" {
  description = <<EOT
  Name of the Key Vault secret that stores the public certificate
  EOT
  type        = string
}

variable "agw_key_vault_cert_name_private" {
  description = <<EOT
  Name of the Key Vault secret that stores the private certificate
  EOT
  type        = string
  default     = null
}

variable "agw_backend_host" {
  description = <<-EOT
  The target host header or FQDN expected by the Traefik ingress 
  controller for routing.
EOT
  type        = string
}

variable "agw_aks_ip" {
  description = <<-EOT
  The private IP address of the Azure Kubernetes Service (AKS) internal 
  load balancer backend.
  EOT
  type        = string

  validation {
    condition = can(
      regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.agw_aks_ip)
    )
    error_message = "The agw_aks_ip variable must be a valid IPv4 address."
  }
}

variable "nsg_akamai_ips" {
  description = <<EOT
    List of Akamai IPs to allow inbound traffic on port 443. Supports
    IPv4 addresses and CIDR blocks.
  EOT
  type        = list(string)
  default     = []
  validation {
    condition = alltrue(
      [
        for ip in var.nsg_akamai_ips : can(
          regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}?$", ip)
        )
      ]
    )
    error_message = <<EOT
    All elements in nsg_akamai_ips must be valid IPv4 addresses 
    EOT
  }
}

variable "role_based_kv" {
  description = <<-EOT
  Specifies whether the Key Vault uses Azure Role-Based Access Control 
  (RBAC) instead of access policies.
EOT
  type        = bool
  default     = false
}

variable "agw_role_definition_name" {
  description = <<EOT
  The Azure RBAC role definition name (e.g., 'Key Vault Secrets User') 
  assigned to the Application Gateway identity for secret access.
  EOT
  type        = string
  default     = ""

  validation {
    condition     = !var.role_based_kv || var.agw_role_definition_name != ""
    error_message = <<EOT
    Variable 'agw_role_definition_name' must not be empty 
    when 'role_based_kv' is true.
    EOT
  }
}

variable "enable_dual_gateway" {
  description = <<EOT
  Controls whether to share a single Application Gateway for NBS 7 
  and NBS 6 traffic. When set to false, a separate gateway is required for
  NBS 6
  EOT
  type        = bool
  default     = true
}

variable "agw_public_hostname" {
  description = <<EOT
  The public FQDN mapped to the Application Gateway public listener.
  EOT
  type        = string

  validation {
    condition = can(
      regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.agw_public_hostname)
    )
    error_message = <<EOT
    The agw_public_hostname must be a valid fully qualified domain name (FQDN)
    EOT
  }
}

variable "agw_private_ip" {
  description = <<EOT
    The static private IP address assigned to the Application Gateway
    frontend configuration.
  EOT
  type        = string
  default     = null

  validation {
    condition = var.enable_dual_gateway == true && (
      var.agw_private_ip != null && (
        can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.agw_private_ip))
      )
    )
    error_message = <<EOT
    The agw_private_ip variable must not be null and must be a valid 
    IPv4 address when enable_dual_gateway is true
    EOT
  }
}

variable "agw_private_backend_host" {
  description = <<EOT
    The target backend host header/FQDN used for internal routing by
    the Application Gateway.
  EOT
  type        = string
  default     = null

  validation {
    condition     = !var.enable_dual_gateway == true || (var.agw_private_backend_host != null)
    error_message = "The agw_private_backend_host variable must not be null when enable_dual_gateway is true"
  }
}

variable "agw_nbs_ip_private" {
  description = <<-EOT
    Private IP address for the internal NBS 6 backend service target
    pool.
  EOT
  type        = string
  default     = null

  validation {
    condition = !var.enable_dual_gateway == true || (
      var.agw_nbs_ip_private != null && (
        can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.agw_nbs_ip_private))
      )
    )
    error_message = "The agw_nbs_ip_private variable must not be null and must be a valid IPv4 address when enable_dual_gateway is true"
  }
}

variable "agw_private_hostname" {
  description = <<EOT
  The private FQDN mapped to the Application Gateway private listener
  EOT
  type        = string
  default     = null

  validation {
    condition = var.enable_dual_gateway == true && (
      var.agw_private_hostname != null && (
        can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.agw_private_hostname))
      )
    )
    error_message = <<EOT
    The agw_private_hostname must not be null and must be a valid 
    fully qualified domain name (FQDN) when enable_dual_gateway is true
    EOT
  }
}
