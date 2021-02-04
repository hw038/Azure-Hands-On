
resource "azurerm_public_ip" "example" {
  name                = var.elb_PIP
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = var.elb_lbrule
  location            = var.rg_location
  resource_group_name = var.rg_name

  frontend_ip_configuration {
    name                 = var.elb_PIP
    public_ip_address_id = azurerm_public_ip.example.id
  }
}