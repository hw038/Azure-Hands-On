

output "id" {
    description = "virtual network gateway name : id 전달"
    value = {
        for vgw in azurerm_virtual_network_gateway.tfmodule:
        vgw.name => vgw.id
    }
}

output "pip" {
    description = "생성된 모든 public ip 정보를 name: id 형태로 전달"

    value = {
        for pip in azurerm_public_ip.tfmodule:
        pip.name => pip.ip_address
    }
}




output "public_ip_address" {
    description = "생성된 모든 public ip 정보를 name: id 형태로 전달"

    value = {
        for pip in data.azurerm_public_ip.tfmodule:
        pip.name => pip.ip_address
    }
}