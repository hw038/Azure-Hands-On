locals {

  set_id = [
    for s in var.vgw: [
      lookup(var.subnet_id, s[8], "")
    ]
  ]

}
resource "azurerm_public_ip" "tfmodule" {
  count               = length(var.vgw)
  name                = var.vgw[count.index][5]
  location            = var.vgw[count.index][1]
  resource_group_name = var.vgw[count.index][0]
  #sku                 = "Standard"
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "tfmodule" {
  count               = length(var.vgw)
  name                = var.vgw[count.index][2]
  location            = var.vgw[count.index][1]
  resource_group_name = var.vgw[count.index][0]

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    #name                          = var.vgw[count.index][5]
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.tfmodule[count.index].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = local.set_id[count.index][0]
  }

  vpn_client_configuration {
    address_space = [var.vgw[count.index][4]]
    
  }
}
