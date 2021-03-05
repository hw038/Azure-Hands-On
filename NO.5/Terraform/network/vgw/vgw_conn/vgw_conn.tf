locals {

  set_id = [
    for s in var.route: [
      lookup(var.ip_private, s[4], ""), lookup(var.subnet_id, s[5], "")
    ]
  ]

}

resource "azurerm_virtual_network_gateway_connection" "onpremise" {
  name                = "onpremise"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.example.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremise.id

  shared_key = "xptmxm123"
}
