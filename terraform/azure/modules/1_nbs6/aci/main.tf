### Deploy NBS6 in ACI ###

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aci_log" {
  name                = "${var.resource_prefix}-aci-log"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 60
  lifecycle {
    ignore_changes = [ 
      tags["business_steward"],
      tags["center"],
      tags["environment"],
      tags["escid"],
      tags["funding_source"],
      tags["pii_data"],
      tags["security_compliance"],
      tags["security_steward"],
      tags["support_group"],
      tags["system"],
      tags["technical_poc"],
      tags["technical_steward"],
      tags["zone"]
      ]
    }
}

# Create Container Group
resource "azurerm_container_group" "aci" {
  depends_on          = [ azurerm_log_analytics_workspace.aci_log ]
  name                = "${var.resource_prefix}-aci"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Windows"
  ip_address_type     = "Private"
  subnet_ids          = toset([data.azurerm_subnet.aci_subnet.id])

 dynamic identity {
    for_each = var.aci_use_private_acr ? [1] : []
    content {
      type = "UserAssigned"
      identity_ids = [data.azurerm_user_assigned_identity.user_assigned_identity.id]
    }
  }

  dynamic image_registry_credential {
    for_each = var.aci_use_private_acr ? [1] : []
    content {
      user_assigned_identity_id = data.azurerm_user_assigned_identity.user_assigned_identity.id
      server = var.aci_private_acr_server_url
    }
  }

  container {
    name   = "${var.resource_prefix}-container"
    image  = var.aci_nbs6_repository
    cpu    = var.aci_cpu
    memory = var.aci_memory
    ports {
      port     = 7001
      protocol = "TCP"
    }

    environment_variables = {
      DATABASE_ENDPOINT = data.azurerm_mssql_managed_instance.sqlmi_endpoint.fqdn
      GITHUB_RELEASE_TAG = var.aci_github_release_tag
    }

  }


  diagnostics {
    log_analytics {
      workspace_id = azurerm_log_analytics_workspace.aci_log.workspace_id
      workspace_key = azurerm_log_analytics_workspace.aci_log.primary_shared_key
    }
  }

  lifecycle {
    ignore_changes = [ 
      tags["business_steward"],
      tags["center"],
      tags["environment"],
      tags["escid"],
      tags["funding_source"],
      tags["pii_data"],
      tags["security_compliance"],
      tags["security_steward"],
      tags["support_group"],
      tags["system"],
      tags["technical_poc"],
      tags["technical_steward"],
      tags["zone"]
      ]
    }
}