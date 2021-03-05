locals {
  nic_id = {
    for p1 in var.jumpbox: 
      p1[0] => [ 
        for p2 in p1[1]:
          lookup(var.nic_id, p2, "")
      ]    
  }

  avset_id = {
    for p in var.jumpbox:
      p[0] => lookup(var.avset_id, p[3], "")
  }
  # string_settings = jsonencode({
  #   "commandToExecute" = var.extension
  # })

}

resource "azurerm_virtual_machine" "tfmodule" {
    count                         = length(var.jumpbox)    
    resource_group_name           = var.resource_group_name
    location                      = var.location  
    name                          = var.jumpbox[count.index][0]    
    vm_size                       = var.jumpbox[count.index][2]
    network_interface_ids         = lookup(local.nic_id, var.jumpbox[count.index][0], [])
    availability_set_id           = ""
    primary_network_interface_id  = lookup(local.nic_id, var.jumpbox[count.index][0], [])[0]
    delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.jumpbox[count.index][4][0]
    offer     = var.jumpbox[count.index][4][1]
    sku       = var.jumpbox[count.index][4][2]
    version   = var.jumpbox[count.index][4][3]
  }
  storage_os_disk {
    name              = "${var.jumpbox[count.index][0]}-disk-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.jumpbox[count.index][5][0] == "H" ? "Standard_LRS" : var.jumpbox[count.index][5][0] == "S" ? "StandardSSD_LRS" : "Premium_LRS"
    disk_size_gb      = var.jumpbox[count.index][5][1]
  }
  os_profile {
    computer_name  = var.jumpbox[count.index][0]
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled = var.jumpbox[count.index][6] == "" ? false : true
    storage_uri = var.jumpbox[count.index][6] == "" ? "" : "https://${var.jumpbox[count.index][6]}.blob.core.windows.net/"
  }

  tags = {
    var.jumpbox[count.index][7][1] = var.jumpbox[count.index][7][1]
  }
}
