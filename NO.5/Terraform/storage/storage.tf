resource "azurerm_storage_account" "tfmodule" {
    count                           = length(var.storages)    
    location                        = var.location
    resource_group_name             = var.resource_group_name    
    name                            = var.storages[count.index][0]
    account_tier                    = var.storages[count.index][1] == "P" ? "Premium" : "Standard"
    account_replication_type        = var.storages[count.index][2]
} 

