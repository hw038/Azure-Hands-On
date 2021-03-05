output "pip" {
    description = "virtual network gateway public name : ip 전달"

    value = {
        for pip in azurerm_public_ip.tfmodule:
        pip.name => pip.ip_address
    }
}


output "id" {
    description = "virtual network gateway name : id 전달"
    value = {
        for vgw in azurerm_virtual_network_gateway.tfmodule:
        vgw.name => vgw.id
    }
}
