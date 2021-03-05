locals {
  lb_id = {
      for p in azurerm_lb.tfmodule:
        p.name => p.id
  }

  backendpool_id = {
      for p in azurerm_lb_backend_address_pool.tfmodule:
        element(split("/",p.loadbalancer_id), length(split("/",p.loadbalancer_id))-1) => p.id
  }  

  probe_id = {
      for p in azurerm_lb_probe.tfmodule:
        "${element(split("/",p.loadbalancer_id), length(split("/",p.loadbalancer_id))-1)}-${p.name}" => p.id
  }  
}

resource "azurerm_lb" "tfmodule" {
  count               = length(var.lbs)
  name                = var.lbs[count.index][0]
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.lbs[count.index][1] == "S" ? "Standard" : "Basic"

  frontend_ip_configuration {
    name                          = "${var.lbs[count.index][0]}-frontend"
    subnet_id                     = lookup(var.subnet_id, var.lbs[count.index][1], [])
    private_ip_address_allocation = var.lbs[count.index][2] == "S" ? "Static" : "Dynamic"
    private_ip_address            = var.lbs[count.index][2] == "S" ? var.lbs[count.index][3] : ""
  }
}

resource "azurerm_lb_backend_address_pool" "tfmodule" {
  count                           = length(var.lbs)
  resource_group_name             = var.resource_group_name
  loadbalancer_id                 = azurerm_lb.tfmodule[count.index].id
  name                            = "${var.lbs[count.index][0]}-backendpool"
}

resource "azurerm_lb_probe" "tfmodule" {
  count                           = length(var.probes)
  resource_group_name             = var.resource_group_name
  loadbalancer_id                 = lookup(local.lb_id, var.probes[count.index][0],"") 
  name                            = var.probes[count.index][1]   
  protocol                        = var.probes[count.index][2]
  port                            = var.probes[count.index][3]
  request_path                    = var.probes[count.index][4] == "" ? "" : var.probes[count.index][2] == "tcp" ? "" : var.probes[count.index][4]
  interval_in_seconds             = "5" //default
  number_of_probes                = "2"
}

resource "azurerm_lb_rule" "tfmodule" {
  count                           = length(var.rules)
  resource_group_name             = var.resource_group_name
  loadbalancer_id                 = lookup(local.lb_id, var.rules[count.index][0])
  name                            = var.rules[count.index][1]    
  protocol                        = var.rules[count.index][2]
  frontend_port                   = var.rules[count.index][3]
  backend_port                    = var.rules[count.index][4]
  frontend_ip_configuration_name  = "${var.rules[count.index][0]}-frontend"
  enable_floating_ip              = false
  backend_address_pool_id         = lookup(local.backendpool_id, var.rules[count.index][0],"")
  probe_id                        = lookup(local.probe_id, "${var.rules[count.index][0]}-${var.rules[count.index][5]}","")
  idle_timeout_in_minutes         = 4
  load_distribution = "Default"
}