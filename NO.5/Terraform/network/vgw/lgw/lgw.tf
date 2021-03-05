locals {

  set_id = [
    for s in var.route: [
      lookup(var.ip_private, s[4], ""), lookup(var.subnet_id, s[5], "")
    ]
  ]

}
resource "azurerm_local_network_gateway" "tfmodule" {
  name                = "backHome"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  gateway_address     = "12.13.14.15"
  address_space       = ["10.0.0.0/16"]
}
