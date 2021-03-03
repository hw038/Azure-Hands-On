
# 리소스 그룹
module "rg" {
  source = "./rg"
  rg_name = var.rg_name
  rg_location = var.rg_location
}

################### NSG 생성 ###################
resource "azurerm_network_security_group" "nsg1" {
  name                = "${var.rg_name}-nsg1"
  location            = var.rg_location
  resource_group_name = var.rg_name
  depends_on = [module.rg]

  security_rule {
    name                       = "Allow_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "Allow_RDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}


################### vnet ###################
resource "azurerm_virtual_network" "vnet01" {
  name                = var.name.vnet01
  resource_group_name = var.rg_name
  location            = var.rg_location
  address_space       = [var.azure_cidr.cidr_vnet01]
  depends_on = [module.rg]

}

################### subnet ###################
resource "azurerm_subnet" "subnet01" {
  name                 = var.name.subnet01
  resource_group_name = var.rg_name
  virtual_network_name = var.name.vnet01
  address_prefixes     = [var.azure_cidr.cidr_subnet01]
  depends_on = [module.rg, azurerm_virtual_network.vnet01]
}

resource "azurerm_subnet_network_security_group_association" "nsg01-subnet01" {
  subnet_id                 = azurerm_subnet.subnet01.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
  depends_on = [module.rg, azurerm_virtual_network.vnet01]
}


################### VM NIC 생성 ###################


################### AVset 생성 ###################
resource "azurerm_availability_set" "AVSet01" {
  name                = "${var.rg_name}-AVSet01"
  location            = var.rg_location
  resource_group_name = var.rg_name
  depends_on = [module.rg]

}






################### elb 생성 ###################
resource "azurerm_public_ip" "elb_pip" {
  name                = var.elb_PIP
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [module.rg]

}

resource "azurerm_lb" "elb" {
  name                = "${var.rg_name}-elb"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  depends_on          = [module.rg, azurerm_public_ip.elb_pip]

  frontend_ip_configuration {
    name                 = var.elb_PIP
    public_ip_address_id = azurerm_public_ip.elb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "elb_backendpool" {
  resource_group_name = var.rg_name
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "elb_backendpool"
  depends_on          = [module.rg, azurerm_lb.elb]
}

# resource "azurerm_network_interface_backend_address_pool_association" "example" {
#   #network_interface_id    = azurerm_windows_virtual_machine_scale_set.tfmodule.network_interface
#   network_interface_id    = "vmss-01-NIC"
#   ip_configuration_name   = "vmss-01-int"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backendpool.id
# }


# resource "azurerm_network_interface_backend_address_pool_association" "vm01-back" {
#   network_interface_id    = azurerm_network_interface.vm01-nic.id
#   ip_configuration_name   = "internal"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backendpool.id
#   depends_on          = [module.rg, azurerm_lb.elb, azurerm_lb_backend_address_pool.elb_backendpool, azurerm_network_interface.vm01-nic]

# }

# resource "azurerm_network_interface_backend_address_pool_association" "vm02-back" {
#   network_interface_id    = azurerm_network_interface.vm02-nic.id
#   ip_configuration_name   = "internal"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backendpool.id
#   depends_on          = [module.rg, azurerm_lb.elb, azurerm_lb_backend_address_pool.elb_backendpool, azurerm_network_interface.vm02-nic]

# }


# resource "azurerm_lb_nat_rule" "elbrule01" {
#   resource_group_name             = var.rg_name
#   loadbalancer_id                = azurerm_lb.elb.id
#   name                           = "VM01-SSH"
#   protocol                       = "Tcp"
#   frontend_port                  = 30001
#   backend_port                   = 22
#   frontend_ip_configuration_name = var.elb_PIP
#   depends_on          = [module.rg, azurerm_lb.elb]

# }

# resource "azurerm_lb_nat_rule" "elbrule02" {
#   resource_group_name             = var.rg_name
#   loadbalancer_id                = azurerm_lb.elb.id
#   name                           = "VM02-SSH"
#   protocol                       = "Tcp"
#   frontend_port                  = 30002
#   backend_port                   = 22
#   frontend_ip_configuration_name = var.elb_PIP
#   depends_on          = [module.rg, azurerm_lb.elb]

# }


# # NIC - Nat rule association
# resource "azurerm_network_interface_nat_rule_association" "vm01_ssh" {
#   network_interface_id  = azurerm_network_interface.vm01-nic.id
#   ip_configuration_name = "internal"
#   nat_rule_id           = azurerm_lb_nat_rule.elbrule01.id
#   depends_on          = [module.rg, azurerm_lb.elb, azurerm_lb_nat_rule.elbrule01, azurerm_network_interface.vm01-nic]

# }

# resource "azurerm_network_interface_nat_rule_association" "vm02_ssh" {
#   network_interface_id  = azurerm_network_interface.vm02-nic.id
#   ip_configuration_name = "internal"
#   nat_rule_id           = azurerm_lb_nat_rule.elbrule02.id
#   depends_on          = [module.rg, azurerm_lb.elb, azurerm_lb_nat_rule.elbrule02, azurerm_network_interface.vm02-nic]

# }

resource "azurerm_lb_probe" "elb_probe" {
  resource_group_name = var.rg_name
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "HTTP-running-probe"
  port                = 80
  depends_on          = [module.rg, azurerm_lb.elb]

}

resource "azurerm_lb_rule" "elb-lbrule" {
  resource_group_name = var.rg_name
  loadbalancer_id     = azurerm_lb.elb.id
  name                           = "ELB-HTTP-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.elb_PIP
  backend_address_pool_id        = azurerm_lb_backend_address_pool.elb_backendpool.id
  probe_id                        = azurerm_lb_probe.elb_probe.id
  #disable_outbound_snat           = "true"
  depends_on          = [module.rg, azurerm_lb.elb, azurerm_lb_probe.elb_probe]

}


#VMSS용
resource "azurerm_lb_nat_pool" "elb" {
  resource_group_name            = var.rg_name
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "VMSS-RDP"
  protocol                       = "Tcp"
  frontend_port_start            = 30001
  frontend_port_end              = 30010
  backend_port                   = 22
  frontend_ip_configuration_name = var.elb_PIP
  #depends_on          = [module.rg, azurerm_lb.elb, azurerm_lb_probe.elb_probe]

}



################### VMSS 생성 ###################

resource "azurerm_linux_virtual_machine_scale_set" "tfmodule" {
  resource_group_name           = var.rg_name
  location                      = var.rg_location  
  name                          = "vmss-01"
  sku                           = "Standard_F2"
  instances                     = 2
  disable_password_authentication = false
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  depends_on          = [module.rg, azurerm_lb.elb, azurerm_lb_probe.elb_probe, azurerm_lb_nat_pool.elb]
  upgrade_mode = "Automatic"
  
  os_disk {
    storage_account_type        = "StandardSSD_LRS"
    caching                     = "ReadWrite"
  }
  automatic_os_upgrade_policy {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = false
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # rolling_upgrade_policy {
  #   max_batch_instance_percent              = 20
  #   max_unhealthy_instance_percent          = 20
  #   max_unhealthy_upgraded_instance_percent = 5
  #   pause_time_between_batches              = "PT0S"
  # }

  # required when using rolling upgrade policy
  health_probe_id = azurerm_lb_probe.elb_probe.id

  network_interface {
    name    = "vmss-01-NIC"
    primary = true

    ip_configuration {
      name      = "vmss-01-int"
      primary   = true
      subnet_id = azurerm_subnet.subnet01.id
      public_ip_address{
        name = azurerm_public_ip.elb_pip.name
      }
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.elb_backendpool.id]
      load_balancer_inbound_nat_rules_ids = [azurerm_lb_nat_pool.elb.id]
      
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "tfmodule" {
  #count                           = length(var.vmss)
  name                            = "nginx"
  virtual_machine_scale_set_id    = azurerm_linux_virtual_machine_scale_set.tfmodule.id
  publisher                       = "Microsoft.Azure.Extensions"
  type                            = "CustomScript"
  type_handler_version            = "2.0"
  # auto_upgrade_minor_version      = true
  settings = jsonencode({
    "commandToExecute" = "apt-get -y update && apt-get -y install nginx && hostname > /var/www/html/index.html"
  })
}

# settings = jsonencode({
#     "commandToExecute" = "sudo apt-get -y update && sudo apt-get -y install nginx && hostname > index.html && sudo mv index.html /var/www/html/"
#   })

# Windows Server인 경우 
# settings = <<SETTINGS
#     {
#         "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
#     }
#   SETTINGS










# module "vnet01" {
#   source = "./modules/network"
#   rg_name = var.rg_name
#   rg_location = var.rg_location
#   depends_on = [module.rg]
# }

# module "vm" {
#   source = "./modules/vm"
#   rg_name = var.rg_name
#   rg_location = var.rg_location
#   network_interface_ids = [
#     azurerm_network_interface.vm01-nic.id,
#   ]
#   depends_on = [module.vnet01]

# }

# module "elb"{
#   source = "./modules/elb"
#   rg_name = var.rg_name
#   rg_location = var.rg_location
#   elb_PIP = "${var.rg_name}-elb_PIP"
#   elb_lbrule = "${var.rg_name}-elb_lbrule"
# }

