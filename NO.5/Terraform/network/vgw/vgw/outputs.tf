

output "id" {
    description = "virtual network gateway name : id 전달"
    value = {
        for vgw in azurerm_virtual_network_gateway.tfmodule:
        vgw.name => vgw.id
    }
}
