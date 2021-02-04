output "vm_public_ip" {
    value = azurerm_public_ip.elb_pip.fqdn
}
