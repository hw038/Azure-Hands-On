resource "azurerm_virtual_network_peering" "peer1to2" {
  name                      = "peer1to2"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet1name
  remote_virtual_network_id = var.vnet2id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "peer2to1" {
  name                      = "peer2to1"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet2name
  remote_virtual_network_id = var.vnet1id
  allow_forwarded_traffic = true
  use_remote_gateways       = true
}
