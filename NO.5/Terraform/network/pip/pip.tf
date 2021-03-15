resource "azurerm_public_ip" "tfmodule" {
    count                       = length(var.public_ips)
    location                    = var.public_ips[count.index][4]
    resource_group_name         = var.public_ips[count.index][3]
    name                        = var.public_ips[count.index][0]
    sku                         = var.public_ips[count.index][1] == "S" ? "Standard" : "Basic"
    allocation_method           = var.public_ips[count.index][2] == "D" ? "Dynamic" : "Static"    
}