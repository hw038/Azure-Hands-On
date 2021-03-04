locals {
  set_id = [
    for s in var.bastion: [
      lookup(var.subnet_id, s[2], ""), lookup(var.pip_id, s[3], "")
    ]
  ]
}

resource "azurerm_bastion_host" "tfmodule" {
  count                           = length(var.bastion)
  name                            = var.bastion[count.index][0]
  location                        = var.location
  resource_group_name             = var.resource_group_name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = local.set_id[count.index][0]
    public_ip_address_id          = local.set_id[count.index][1]
  }
}
