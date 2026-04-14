resource "hcp_hvn" "this" {
  hvn_id         = var.hvn_id
  cloud_provider = "azure"
  region         = var.hcp_region
  cidr_block     = var.hvn_cidr_block
}

resource "hcp_azure_peering_connection" "this" {
  hvn_link                 = hcp_hvn.this.self_link
  peering_id               = var.hvn_peering_id
  peer_subscription_id     = var.azure_subscription_id
  peer_tenant_id           = var.azure_tenant_id
  peer_resource_group_name = azurerm_resource_group.this.name
  peer_vnet_name           = azurerm_virtual_network.this.name
  peer_vnet_region         = azurerm_virtual_network.this.location
  allow_forwarded_traffic  = false
  use_remote_gateways      = false
}

resource "azuread_service_principal" "hcp_peering" {
  client_id    = hcp_azure_peering_connection.this.application_id
  use_existing = true
}

resource "azurerm_role_definition" "hcp_peering" {
  name  = "${var.name_prefix}-hcp-hvn-peering"
  scope = azurerm_virtual_network.this.id

  assignable_scopes = [
    azurerm_virtual_network.this.id
  ]

  permissions {
    actions = [
      "Microsoft.Network/virtualNetworks/peer/action",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
    ]
  }
}

resource "azurerm_role_assignment" "hcp_peering" {
  principal_id       = azuread_service_principal.hcp_peering.object_id
  scope              = azurerm_virtual_network.this.id
  role_definition_id = azurerm_role_definition.hcp_peering.role_definition_resource_id
}

data "hcp_azure_peering_connection" "active" {
  hvn_link              = hcp_hvn.this.self_link
  peering_id            = hcp_azure_peering_connection.this.peering_id
  wait_for_active_state = true

  depends_on = [
    azurerm_role_assignment.hcp_peering
  ]
}

resource "hcp_hvn_route" "azure_vnet" {
  hvn_link         = hcp_hvn.this.self_link
  hvn_route_id     = var.hvn_route_id
  destination_cidr = var.azure_vnet_cidr
  target_link      = data.hcp_azure_peering_connection.active.self_link
}

resource "hcp_vault_cluster" "this" {
  cluster_id      = var.vault_cluster_id
  hvn_id          = hcp_hvn.this.hvn_id
  tier            = "standard_small"
  public_endpoint = false
  proxy_endpoint  = "DISABLED"

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    hcp_hvn_route.azure_vnet
  ]
}
