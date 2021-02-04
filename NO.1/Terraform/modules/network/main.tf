# # 리소스 그룹
# resource "azurerm_resource_group" "rg" {
#   name = var.rg_name
#   location = var.rg_location
# }

################### NSG 생성 ###################
resource "azurerm_network_security_group" "nsg1" {
  name                = "${var.rg_name}-nsg1"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Allow_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
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
    source_port_range          = "3389"
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
    source_port_range          = "80"
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
  subnet {
      name            = var.name.subnet01
      address_prefix  = var.azure_cidr.cidr_subnet01
      security_group  = azurerm_network_security_group.nsg1.id
  }
  # depends_on = [azurerm_subnet.subnet01]

}

################### subnet ###################
resource "azurerm_subnet" "subnet01" {
  name                 = var.name.subnet01
  resource_group_name = var.rg_name
  virtual_network_name = var.name.vnet01
  address_prefixes     = [var.azure_cidr.cidr_subnet01]
  depends_on = [azurerm_virtual_network.vnet01]
}



################### VM NIC 생성 ###################
resource "azurerm_network_interface" "vm01-nic" {
  name                = var.vm01_nic
  location            = var.rg_location
  resource_group_name = var.rg_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.1.0.4"
  }
}

resource "azurerm_network_interface" "vm02-nic" {
  name                = var.vm02_nic
  location            = var.rg_location
  resource_group_name = var.rg_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.1.0.5"
  }
}

