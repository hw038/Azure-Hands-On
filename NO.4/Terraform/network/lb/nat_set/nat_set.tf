locals {
  set_id = [
    for s in var.nat_set: [
      lookup(var.nic_id, s[1], ""), lookup(var.nic_ip_config_name, s[1], ""), lookup(var.nat_rule_id, s[2], "")
    ]
  ]
}
resource "azurerm_network_interface_nat_rule_association" "example" {
  count                 = length(var.nat_set)
  network_interface_id  = local.set_id[count.index][0]
  ip_configuration_name = local.set_id[count.index][1]
  nat_rule_id           = local.set_id[count.index][2]
}
