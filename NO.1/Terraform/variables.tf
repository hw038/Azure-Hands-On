variable "rg_name" {
  description = "The prefix used for all resources in this example"
  default = "Hands-On-NO.1"
}

variable "rg_location" {
  description = "The Azure location where all resources in this example should be created"
  default = "eastus"
}

variable "cred" {
  description = "user ID / Password"
  type = map
  default = {
    id = "azureuser"
    pw = "Azurexptmxm123"
  }
}



variable "vm01_nic" {
  description = "The Azure location where all resources in this example should be created"
  default = "vm01_nic"
}

variable "vm02_nic" {
  description = "The Azure location where all resources in this example should be created"
  default = "vm02_nic"
}


variable "vm03_nic" {
  description = "The Azure location where all resources in this example should be created"
  default = "vm03_nic"
}

variable "vm04_nic" {
  description = "The Azure location where all resources in this example should be created"
  default = "vm04_nic"
}




variable "azure_cidr" {
  type = map
  default = {
    cidr_vnet01 = "10.0.0.0/8"
    cidr_vnet02 = "192.168.0.0/16"
    cidr_subnet01 = "10.1.0.0/16"
    cidr_subnet02 = "192.168.1.0/26"
  }
  description = "Azure CIDR for vnet & subnet"
}
  
variable "name" {
  default = {
    vnet01 = "vnet01"
    vnet02 = "vnet02"
    subnet01 = "subnet01"
    subnet02 = "subnet02"
  }
}  


variable "elb_name" {
  description = "The Azure location where all resources in this example should be created"
  default = ""
}
variable "elb_PIP" {
  description = "The Azure location where all resources in this example should be created"
  default = "elb_PIP"
}


variable "elb_lbrule" {
  description = "The Azure location where all resources in this example should be created"
  default = "elb_lbrule"
}
