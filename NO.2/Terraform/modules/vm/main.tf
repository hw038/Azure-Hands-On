
resource "azurerm_availability_set" "AVSet01" {
  name                = "${var.rg_name}-AVSet01"
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = var.vm01
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm01-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}