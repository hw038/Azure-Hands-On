output "pip" {
    description = "virtual network gateway public ip 전달"

    value = azurerm_public_ip.tfmodule.ip_address
}


output "id" {
    description = "virtual network gateway id 전달"

    value = azurerm_virtual_network_gateway.tfmodule.id
}
