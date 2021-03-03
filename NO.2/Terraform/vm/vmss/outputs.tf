output "vmss_nic" {
    value = {
        for vmss in azurerm_linux_virtual_machine_scale_set.tfmodule:
            vmss.network_interface[0].name => vmss.network_interface.ip_configuration[0].id
    }
}

# output "vmss_ipconf" {
#     value = {
#         for s in azurerm_windows_virtual_machine_scale_set.tfmodule:
#         s.network_interface.ip_configuration.name => s.network_interface.ip_configuration.id
#     }
# }