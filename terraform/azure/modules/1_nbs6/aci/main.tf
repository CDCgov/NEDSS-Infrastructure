### Deploy NBS6 in ACI ###
resource "azurerm_container_group" "aci" {
  name                = "${var.prefix}-aci"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Windows"
  ip_address_type     = "Private"
  subnet_ids          = toset([data.azurerm_subnet.aci_subnet.id])

  container {
    name   = "${var.prefix}-container"
    image  = var.aci_quay_nbs6_repository
    cpu    = var.aci_cpu
    memory = var.aci_memory
    ports {
      port     = 7001
      protocol = "TCP"
    }

    environment_variables = {
      DATABASE_ENDPOINT = var.aci_sql_database_endpoint
      GITHUB_RELEASE_TAG = var.aci_github_release_tag
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