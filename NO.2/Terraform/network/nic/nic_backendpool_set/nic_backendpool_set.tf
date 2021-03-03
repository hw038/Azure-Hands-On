locals {
  set_id = [
    for s in var.nic_backend_pool_set: [
      lookup(var.nic_id, s[2], ""), lookup(var.lb_backendpool_id, s[0], ""), lookup(var.vmss_ipconf, s[3], "")
    ]
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "tfmodule" {
  count                     = length(local.set_id)
  ip_configuration_name     = "vmss-01-int"
  network_interface_id      = local.set_id[count.index][0]
  backend_address_pool_id   = local.set_id[count.index][1]
}
