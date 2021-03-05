locals {

  set_id = [
    for s in var.route: [
      lookup(var.ip_private, s[4], ""), lookup(var.subnet_id, s[5], "")
    ]
  ]

}
resource "azurerm_route_table" "tfmodule" {
  count                           = length(var.route)
  name                            = var.route[count.index][0]
  location                        = var.location
  resource_group_name             = var.resource_group_name
  disable_bgp_route_propagation   = false

  route {
    name                          = var.route[count.index][1]
    address_prefix                = var.route[count.index][2]
    next_hop_type                 = var.route[count.index][3]
    next_hop_in_ip_address        = local.set_id[count.index][0]
  }

}

resource "azurerm_subnet_route_table_association" "tfmodule" {
  count                           = length(var.route)
  subnet_id                       = local.set_id[count.index][1]
  route_table_id                  = azurerm_route_table.tfmodule[count.index].id
}
