
output "id" {
    description = "local network gateway name : id 전달"
    value = {
        for lgw in azurerm_local_network_gateway.tfmodule:
        lgw.name => lgw.id
    }
}
