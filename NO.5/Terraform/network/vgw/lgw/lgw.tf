locals {

  set_id = [
    for s in var.lgw: [
      lookup(var.public_ip, s[5], "")
    ]
  ]

}

resource "azurerm_local_network_gateway" "tfmodule" {
  count               = length(var.lgw)
  name                = var.lgw[count.index][2]
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = local.set_id[count.index][0]
  address_space       = var.lgw[count.index][4] == "" ? [var.lgw[count.index][3]] : [var.lgw[count.index][3],var.lgw[count.index][4]]
}

  
