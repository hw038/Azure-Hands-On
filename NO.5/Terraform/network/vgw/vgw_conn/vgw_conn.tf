locals {

  set_id = [
    for s in var.vgw_conn: [
      lookup(var.vgw_id, s[2], ""), lookup(var.lgw_id, s[3], "")
    ]
  ]

}

resource "azurerm_virtual_network_gateway_connection" "tfmodule" {
  count               = length(var.vgw_conn)
  name                = var.vgw_conn[count.index][4]
  resource_group_name = var.resource_group_name
  location            = var.location
  
  type                       = "IPsec"
  virtual_network_gateway_id = local.set_id[count.index][0]
  local_network_gateway_id   = local.set_id[count.index][1]

  shared_key = var.vgw_conn[count.index][5]
}
