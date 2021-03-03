locals {
  resource_group = "Hands-On-No.2"
  location = "eastus"

  nsg = {
    nsg_names = ["nsg-subnet1"]#,"nsg-subnet2"] 
    nsg_rules = [ 
      ["nsg-subnet1", 100, "port-tcp-3389", 3389, "*", "tcp"],
      ["nsg-subnet1", 110, "port-tcp-80", 80, "*", "tcp"],
      # ["nsg-subnet2", 100, "port-tcp-22", 22, "*", "tcp"],
      # ["nsg-subnet2", 110, "port-tcp-80", 80, "*", "tcp"],
    ],
    nsg_subnet_set = [
      ["subnet1", "nsg-subnet1"],
      # ["subnet2", "nsg-subnet2"]
    ]     
  }

  vnet = {
    address_space = ["10.0.0.0/8"]
    subnets = [
      ["subnet1", "10.1.0.0/16"],
      # ["subnet2", "10.0.2.0/16"],
    ] 
  }

  lb = {
    lbs = [
      ["lb-test-ext","S", "S"]
    ]  
    probes = [
      ["lb-test-ext", "probe-http-80", "http", 80, "/"]
    ] 
    rules = [
      ["lb-test-ext", "rule-http-80","tcp",80,80, "probe-http-80"]
    ] 
    nat = [
      ["lb-test-ext", "VMSS-RDP","tcp",30001,30010,3389]
    ]
  }


  avset_names = ["avset-subnet1"]#, "avset-subnet2"]  

vmss = {
    public_ips = [
      ["vmss-test-01-pip", "S", "S"],
    ],
    vmss=[
      ["vmss-01", ["vmss-test-01-nic-ext"], "Standard", "avset-subnet1",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "", ["tag", "tag1"]],
    ],
    data_disks=[
      ["vmss-test-01", 0, "vmss-test-01-disk-data-0", "H", 32, "ReadWrite"],
    ],
    data_disks_create=[
      ["vmss-test-01-disk-data-1", "H", 32], 
    ],
    data_disks_attach=[                                                  
      ["vmss-test-01", 1, "vmss-test-01-disk-data-1", "ReadWrite"],
    ],
    nic_backend_pool_set=[
      ["lb-test-ext-backendpool", "VMSS-RDP", "vmss-01", "subnet1"],
    ],
  }
}

module "resource_group" {
  source = "./resource_group"  
  name = local.resource_group
  location = local.location
}

module "nsg" {
  source = "./network/nsg/nsg"

  location = module.resource_group.location
  resource_group_name = module.resource_group.name

  nsg_names = local.nsg.nsg_names
  nsg_rules = local.nsg.nsg_rules
}

module "vnet" {
  source = "./network/vnet"  
  vnet_name = "vnet-tf-test"      
  location = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space = local.vnet.address_space
  subnets = local.vnet.subnets
}

module "nsg_subnet_set" {
  source = "./network/nsg/nsg_subnet_set"

  nsg_id = module.nsg.id
  subnet_id = module.vnet.subnet_id
  nsg_subnet_set = local.nsg.nsg_subnet_set
}

module "lb" {
  source = "./network/lb/ext"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  lbs = local.lb.lbs
  probes = local.lb.probes
  rules = local.lb.rules
  nat = local.lb.nat
}


module "avset" {
  source = "./avset"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  avset_names = local.avset_names
}

module "pip" {
  source = "./network/pip"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  public_ips = local.vmss.public_ips
}

# module "nic" {
#   source = "./network/nic/nic"

#   resource_group_name = module.resource_group.name
#   location = module.resource_group.location
#   subnet_id = module.vnet.subnet_id
#   pip_id = module.pip.id
#   nics = local.vmss.nics
# }

module "vmss" {
  source = "./vm/vmss"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  //nic_id = module.nic.id
  subnet_id = module.vnet.subnet_id
  avset_id = module.avset.id
  admin_username = "azureuser"
  admin_password = "Azurexptmxm123"
  vmss = local.vmss.vmss
  # nics = local.vmss.nics
  nic_backend_pool_set = local.vmss.nic_backend_pool_set
  lb_backend_pool = module.lb.backendpool_id2
  lb_nat_pool = module.lb.natpool_id
}


output "avset_id" {
  value = module.avset.id
}

output "lb_ext_id" {
  value = module.lb.id
}

output "lb_ext_backendpool_id" {
  value = module.lb.backendpool_id
}


# output "nic_id" {
#   value = module.nic.id
# }

output "nsg_id" {
  value = module.nsg.id
}

output "nsg_subnet_set_info" {
  value = module.nsg_subnet_set.info
}

output "pip_id" {
  value = module.pip.id
}

output "vnet_name" {
  value = module.vnet.name
}

output "subnet_id" {
  value = module.vnet.subnet_id
}

output "resource_group_id" {
  value = module.resource_group.id
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_location" {
  value = module.resource_group.location
}

# output "storage_id" {
#   value = module.storage.id
# }

# output "data_disk_id" {
#   value = module.data_disk.id
# }

# output "data_disk_create_id" {
#   value = module.data_disk_create.id
# }

# output "data_disk_attach_info" {
#   value = module.data_disk_attach.info
# }




