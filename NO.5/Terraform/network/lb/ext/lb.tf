locals {
  lb_id = {
      for p in azurerm_lb.tfmodule:
        p.name => p.id
  }

  backendpool_id = {
      for p in azurerm_lb_backend_address_pool.tfmodule:
        element(split("/",p.loadbalancer_id), length(split("/",p.loadbalancer_id))-1) => p.id
  }

  backendpool_id2 = {
      for p in azurerm_lb_backend_address_pool.tfmodule:
        p.name => p.id
  }

  probe_id = {
      for p in azurerm_lb_probe.tfmodule:
        "${element(split("/",p.loadbalancer_id), length(split("/",p.loadbalancer_id))-1)}-${p.name}" => p.id
  }  

  # natpool_id = {
  #   for p in azurerm_lb_nat_pool.tfmodule:
  #     p.name => p.id
  # }
}

resource "azurerm_public_ip" "tfmodule" {
    count                       = length(var.lbs)
    location                    = var.location
    resource_group_name         = var.resource_group_name    
    name                        = "${var.lbs[count.index][0]}-pip"    
    sku                         = var.lbs[count.index][1] == "S" ? "Standard" : "Basic"
    allocation_method           = var.lbs[count.index][1] == "S" ? "Static" : var.lbs[count.index][2] == "S" ? "Static" : "Dynamic"
}

resource "azurerm_lb" "tfmodule" {
  count               = length(var.lbs)
  name                = var.lbs[count.index][0]
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.lbs[count.index][1] == "S" ? "Standard" : "Basic"

  frontend_ip_configuration {
    name                          = "${var.lbs[count.index][0]}-frontend"
    public_ip_address_id          = azurerm_public_ip.tfmodule[count.index].id
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
  interval_in_seconds             = "5"
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

# resource "azurerm_lb_nat_pool" "tfmodule" {
#   count                          = length(var.nat)
#   resource_group_name            = var.resource_group_name
#   loadbalancer_id                = lookup(local.lb_id, var.rules[count.index][0])
#   name                           = var.nat[count.index][1]
#   protocol                       = var.nat[count.index][2]
#   frontend_port_start            = var.nat[count.index][3]
#   frontend_port_end              = var.nat[count.index][4]
#   backend_port                   = var.nat[count.index][5]
#   frontend_ip_configuration_name = "${var.nat[count.index][0]}-frontend"
# }


resource "azurerm_lb_nat_rule" "tfmodule" {
  count                          = length(var.nat)
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = lookup(local.lb_id, var.nat[count.index][0])
  name                           = var.nat[count.index][2]
  protocol                       = var.nat[count.index][3]
  frontend_port                  = var.nat[count.index][4]
  backend_port                   = var.nat[count.index][5]
  frontend_ip_configuration_name = "${var.nat[count.index][0]}-frontend"
  
}
