
locals {
  
  # nic_id = {
  #   for p1 in var.vmss: 
  #     p1[0] => [ 
  #       for p2 in p1[1]:
  #         lookup(var.nic_id, p2, "")
  #     ]
  # }
  # set_id = [
  #   for s in var.nics: [
  #     lookup(var.subnet_id, s[0], "")
  #   ]
  # ]
  avset_id = {
    for p in var.vmss:
      p[0] => lookup(var.avset_id, p[3], "")
  }
  
  set_id = [
    for s in var.vmss_subnet_set: [
      lookup(var.subnet_id, s[0], ""), lookup(var.vmss_id, s[1], "") 
    ]
  ]

}

resource "azurerm_linux_virtual_machine_scale_set" "tfmodule" {
    #count                         = length(var.vmss)   
    resource_group_name           = var.resource_group_name
    location                      = var.location  
    name                          = var.vmss[0][0]
    sku                           = "Standard_F2"
    instances                     = 2
    # disable_password_authentication = false
    admin_username                = var.admin_username
    admin_password                = var.admin_password

    os_disk {
      storage_account_type        = "Standard_LRS"
      caching                     = "ReadWrite"

    }

    source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }

  network_interface {
    name    = "vmss-01-NIC"
    primary = true

    ip_configuration {
      name      = "vmss-01-int"
      primary   = true
      subnet_id = var.subnet_id[0].id
      # load_balancer_backend_address_pool_ids = "${local.back_id[count.index][0]}-backendpool"
      # load_balancer_backend_address_pool_ids = local.set_id[count.index][2]
    }
  }

  # boot_diagnostics {
  #   enabled = var.vmss[count.index][6] == "" ? false : true
  #   storage_uri = var.vmss[count.index][6] == "" ? "" : "https://${var.vmss[count.index][6]}.blob.core.windows.net/"
  # }


  # tags = {
  #   var.vmss[count.index][7][1] = var.vmss[count.index][7][1]
  # }
}

resource "azurerm_virtual_machine_scale_set_extension" "tfmodule" {
  #count                           = length(var.vmss)
  name                            = "web_hostname"
  virtual_machine_scale_set_id    = azurerm_linux_virtual_machine_scale_set.tfmodule.id
  publisher                       = "Microsoft.Azure.Extensions"
  type                            = "CustomScript"
  type_handler_version            = "2.0"
  settings = <<SETTINGS
    {
        "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
  SETTINGS
}

