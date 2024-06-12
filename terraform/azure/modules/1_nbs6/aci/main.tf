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

  container {
    name   = "${var.resource_prefix}-container"
    image  = var.aci_quay_nbs6_repository
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
##########################
  container {
      name   = "fluentbit"
      image  = "fluent/fluent-bit:1.7"
      cpu    = "1.0"
      memory = "1.5"

      commands = [
        "fluent-bit.exe",
        "-v",
        "-i", "tail",
        "-p", "path=C:\\nbs\\wildfly-10.0.0.Final\\nedssdomain\\log\\*.log",
        "-o", "splunk",
        "-p", "host=https://http-inputs.cdc.splunkcloudgc.com:443/services/collector/event",
        "-p", "token=<Your-HEC-Token>",
        "-p", "tls=On",
        "-p", "tls.verify=Off",
        "-p", "splunk_send_raw=On",
        "-p", "format=json"
      ]
      volume {
        name       = "fluentbit-logs"
        mount_path = "C:\\nbs\\wildfly-10.0.0.Final\\nedssdomain\\log"
        read_only  = true
      }
    }
###########################################
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

##########################
