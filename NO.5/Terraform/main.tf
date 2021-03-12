locals {
  resource_group = "Hands-On-NO.5"
  location = "eastus"

  resource_group2 = "Hands-On-NO.5-On"
  location2 = "westus"


  storage = {
    storages = [ 
      ["no5storagehh", "S", "LRS"],
    ]
    
  }

  nsg = {
    nsg_names = ["NO.5-NSG01"] 
    nsg_rules = [ 
      ["NO.5-NSG01", 100, "port-tcp-22", 22, "*", "tcp"],
      ["NO.5-NSG01", 110, "port-tcp-80", 80, "*", "tcp"],
    ],
    nsg_subnet_set = [
      ["NO.5-Subnet01", "NO.5-NSG01"],
    ]     
  }
  
  nsg2 = {
    nsg_names = ["NO.5-NSG02"] 
    nsg_rules = [ 
      ["NO.5-NSG02", 100, "port-tcp-22", 22, "*", "tcp"],
      ["NO.5-NSG02", 110, "port-tcp-80", 80, "*", "tcp"],
    ],
    nsg_subnet_set = [
      ["NO.5-Subnet02", "NO.5-NSG02"]
    ]     
  }

  nsg_On = {
    nsg_names = ["NO.5-On-NSG"] 
    nsg_rules = [ 
      ["NO.5-On-NSG", 100, "port-tcp-22", 22, "*", "tcp"],
      ["NO.5-On-NSG", 110, "port-tcp-80", 80, "*", "tcp"],
    ],
    nsg_subnet_set = [
      ["NO.5-On-Subnet", "NO.5-On-NSG"]
    ]     
  }

  vnet = {
    name = "NO.5-VNet01"
    address_space = ["10.0.0.0/8"]
    subnets = [
      ["NO.5-Subnet01", "10.1.0.0/16"],
      ["GatewaySubnet", "10.100.100.0/24"],
    ] 
  }

  vnet2 = {
    name = "NO.5-VNet02"
    address_space = ["192.168.0.0/16"]
    subnets = [
      ["NO.5-Subnet02", "192.168.1.0/26"],
    ] 
  }

  vnet_On = {
    name = "NO.5-On-VNet"
    address_space = ["20.0.0.0/16"]
    subnets = [
      ["NO.5-On-Subnet", "20.0.0.0/24"],
      ["GatewaySubnet", "20.0.100.0/24"],
    ] 
  }

  lb = {
    lbs = [
      ["NO.5-LB-EXT","S", "S"]
    ]  
    probes = [
      ["NO.5-LB-EXT", "probe-http-80", "http", 80, "/"]
    ] 
    rules = [
      ["NO.5-LB-EXT", "rule-http-80","tcp",80,80, "probe-http-80"]
    ]
    nat = [
      ["NO.5-LB-EXT", "vm-test-01-nic-ext","SSH-VM01","tcp",30001,22],
      ["NO.5-LB-EXT", "vm-test-02-nic-ext","SSH-VM02","tcp",30002,22]
    ]
  }

  route = {
    table = [
      ["NO.5-RT","route1", "192.168.0.0/16","VirtualAppliance", "vm-test-03-nic-int", "NO.5-Subnet01"]
    ]  
  }

  gateway = {
    vgw = [
      ["${module.resource_group.name}","${module.resource_group.location}","NO.5-VGW","10.100.100.0/24","20.0.0.0/16","VGW-PIP","NO.5-VNet01","NO.5-Subnet01","GatewaySubnet"],
    ]
    lgw = [
      ["${module.resource_group.name}","${module.resource_group.location}","NO.5-LGW","20.0.0.0/16","","VGW-Onprem-PIP","NO.5-VNet01"],
    ]
    vgw_conn = [
      ["${module.resource_group.name}","${module.resource_group.location}","NO.5-VGW","NO.5-LGW","NO.5-VGW-Conn","xptmxm123"],
    ]
  }

  gateway_On = {
    vgw = [
      ["${module.resource_group2.name}","${module.resource_group2.location}","NO.5-VGW-Onprem","20.0.0.0/16","10.100.100.0/24","VGW-Onprem-PIP","NO.5-On-VNet","NO.5-On-Subnet","GatewaySubnet"],
    ]
    lgw = [
      ["${module.resource_group2.name}","${module.resource_group2.location}","NO.5-LGW-Onprem","10.0.0.0/8","192.168.0.0/16","VGW-PIP","NO.5-VNet01"],
    ]
    vgw_conn = [
      ["${module.resource_group2.name}","${module.resource_group2.location}","NO.5-VGW-Onprem","NO.5-LGW-Onprem","NO.5-VGW-On-Conn","xptmxm123"],
    ]
  }

  avset_names = ["NO.5-AVset01"]

  vm = {
    public_ips = [
      ["", "S", "S"],
      ["", "S", "S"]
    ],
    nics = [
      ["vm-test-01-nic-ext", "NO.5-Subnet01", "S","10.1.0.11", "","false"],
      ["vm-test-02-nic-ext", "NO.5-Subnet01", "S","10.1.0.12", "","false"],
    ],     
    vms=[
      ["vm-test-01", ["vm-test-01-nic-ext"], "Standard_F2s", "NO.5-AVset01",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "${module.storage.storagename}", ["tag", "tag1"]],
      ["vm-test-02", ["vm-test-02-nic-ext"], "Standard_F2s", "NO.5-AVset01",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "${module.storage.storagename}", ["tag", "tag2"]],
    ],
    data_disks=[
      ["vm-test-01", 0, "vm-test-01-disk-data-0", "H", 32, "ReadWrite"],
      ["vm-test-02", 0, "vm-test-02-disk-data-0", "H", 32, "ReadWrite"],
    ],
    data_disks_create=[
      ["vm-test-01-disk-data-1", "H", 32], 
      ["vm-test-02-disk-data-1", "H", 32], 
    ],
    data_disks_attach=[
      ["vm-test-01", 1, "vm-test-01-disk-data-1", "ReadWrite"],
      ["vm-test-02", 1, "vm-test-02-disk-data-1", "ReadWrite"],
    ],

    nic_backend_pool_set=[
      ["NO.5-LB-EXT", "vm-test-01-nic-ext"],
      ["NO.5-LB-EXT", "vm-test-02-nic-ext"],
    ],
   
    extension=[
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update && apt-get -y install nginx && hostname > /var/www/html/index.html"],
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update && apt-get -y install nginx && hostname > /var/www/html/index.html"],
    ]
  }

  vm2 = {
    public_ips = [
      ["vm_02_pip", "S", "S"],
    ],
    nics = [
      ["vm-test-03-nic-int", "NO.5-Subnet02", "S","192.168.1.20", "vm_02_pip", "false"],
    ],     
    vms=[
      ["vm-test-03", ["vm-test-03-nic-int"], "Standard_F2s", "NO.5-AVset02",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "${module.storage.storagename}", ["tag", "tag2"]],
    ],
    data_disks=[
      ["vm-test-03", 0, "vm-test-03-disk-data-0", "H", 32, "ReadWrite"],
    ],
    data_disks_create=[
      ["vm-test-03-disk-data-1", "H", 32], 
    ],
    data_disks_attach=[
      ["vm-test-03", 1, "vm-test-03-disk-data-1", "ReadWrite"],
    ],

  }

  vm_On = {
    public_ips = [
      ["vm_On_pip", "S", "S"],
    ],
    nics = [
      ["vm-On-nic-int", "NO.5-On-Subnet", "S","20.0.0.20", "vm_On_pip", "false"],
    ],     
    vms=[
      ["vm-On", ["vm-On-nic-int"], "Standard_F2s", "",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "", ["tag", "tag2"]],
    ],
    data_disks=[
      ["vm-On", 0, "vm-On-disk-data-0", "H", 32, "ReadWrite"],
    ],
    data_disks_create=[
      ["vm-On-disk-data-1", "H", 32], 
    ],
    data_disks_attach=[
      ["vm-On", 1, "vm-On-disk-data-1", "ReadWrite"],
    ],

  }
}

module "resource_group" {
  source = "./resource_group"  
  name = local.resource_group
  location = local.location
}
module "resource_group2" {
  source = "./resource_group"  
  name = local.resource_group2
  location = local.location2
}

module "storage" {
  source = "./storage"
  
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  storages = local.storage.storages
}

module "nsg" {
  source = "./network/nsg/nsg"

  location = module.resource_group.location
  resource_group_name = module.resource_group.name

  nsg_names = local.nsg.nsg_names
  nsg_rules = local.nsg.nsg_rules
}

module "nsg2" {
  source = "./network/nsg/nsg"

  location = module.resource_group.location
  resource_group_name = module.resource_group.name

  nsg_names = local.nsg2.nsg_names
  nsg_rules = local.nsg2.nsg_rules
}

module "nsg_On" {
  source = "./network/nsg/nsg"

  location = module.resource_group2.location
  resource_group_name = module.resource_group2.name

  nsg_names = local.nsg_On.nsg_names
  nsg_rules = local.nsg_On.nsg_rules
}


module "vnet" {
  source = "./network/vnet"  
  vnet_name = local.vnet.name
  location = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space = local.vnet.address_space
  subnets = local.vnet.subnets
}

module "vnet2" {
  source = "./network/vnet"  
  vnet_name = local.vnet2.name 
  location = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space = local.vnet2.address_space
  subnets = local.vnet2.subnets
}

module "vnet_On" {
  source = "./network/vnet"  
  vnet_name = local.vnet_On.name 
  location = module.resource_group2.location
  resource_group_name = module.resource_group2.name
  address_space = local.vnet_On.address_space
  subnets = local.vnet_On.subnets
}

module "peering" {
  source = "./network/peering"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  vnet1name = local.vnet.name
  vnet2name = local.vnet2.name
  vnet1id = module.vnet.vnet_id
  vnet2id = module.vnet2.vnet_id

}


module "nsg_subnet_set" {
  source = "./network/nsg/nsg_subnet_set"

  nsg_id = module.nsg.id
  subnet_id = module.vnet.subnet_id
  nsg_subnet_set = local.nsg.nsg_subnet_set
}


module "nsg_subnet_set2" {
  source = "./network/nsg/nsg_subnet_set"

  nsg_id = module.nsg2.id
  subnet_id = module.vnet2.subnet_id
  nsg_subnet_set = local.nsg2.nsg_subnet_set
}

module "nsg_subnet_set_On" {
  source = "./network/nsg/nsg_subnet_set"

  nsg_id = module.nsg_On.id
  subnet_id = module.vnet_On.subnet_id
  nsg_subnet_set = local.nsg_On.nsg_subnet_set
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

module "lb_nat_set" {
  source = "./network/lb/nat_set"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  nic_id = module.nic.id
  nic_ip_config_name = module.nic.ip_config_name
  nat_rule_id = module.lb.nat_rule_id
  nat_set = local.lb.nat
  
}

module "avset" {
  source = "./avset"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  avset_names = local.avset_names
}

# module "pip" {
#   source = "./network/pip"

#   resource_group_name = module.resource_group.name
#   location = module.resource_group.location
#   public_ips = local.vm.public_ips
# }

module "nic" {
  source = "./network/nic/nic"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  subnet_id = module.vnet.subnet_id
  #pip_id = module.pip.id
  nics = local.vm.nics
}

module "nic2" {
  source = "./network/nic/nic"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  subnet_id = module.vnet2.subnet_id
  pip_id = module.vm2.pip
  nics = local.vm2.nics
}

module "nic_On" {
  source = "./network/nic/nic"

  resource_group_name = module.resource_group2.name
  location = module.resource_group2.location
  subnet_id = module.vnet_On.subnet_id
  pip_id = module.vm_On.pip
  nics = local.vm_On.nics
}

module "nic_ext_backendpool_set" {
  source = "./network/nic/nic_backendpool_set"

  nic_id = module.nic.id
  lb_backendpool_id = module.lb.backendpool_id
  nic_backend_pool_set = local.vm.nic_backend_pool_set
}

# module "nic_int_backendpool_set" {
#   source = "./network/nic/nic_backendpool_set"

#   nic_id = module.nic.id
#   lb_backendpool_id = module.lb_int.backendpool_id
#   nic_backend_pool_set = local.vm.nic_int_backend_pool_set
# }

module "data_disk" {
  source = "./vm/disk/data_disk_create_attach"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  disks = local.vm.data_disks
  vm_id = module.vm.id
}

module "vm" {
  source = "./vm/vm"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  nic_id = module.nic.id
  avset_id = module.avset.id
  admin_username = "azureuser"
  admin_password = "Azurexptmxm123"
  vms = local.vm.vms
  extension = local.vm.extension
}

module "vm2" {
  source = "./vm/vm2"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  nic_id = module.nic2.id
  avset_id = ""
  admin_username = "azureuser"
  admin_password = "Azurexptmxm123"
  vms = local.vm2.vms
  public_ips = local.vm2.public_ips

}


module "vm_On" {
  source = "./vm/vm_On"

  resource_group_name = module.resource_group2.name
  location = module.resource_group2.location
  nic_id = module.nic_On.id
  avset_id = ""
  admin_username = "azureuser"
  admin_password = "Azurexptmxm123"
  vms = local.vm_On.vms
  public_ips = local.vm_On.public_ips
}

module "routetable" {
  source = "./network/route"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  route = local.route.table
  ip_private = module.nic2.ip_private
  subnet_id = module.vnet.subnet_id
}


module "vgw" {
  source = "./network/vgw/vgw"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  vgw = local.gateway.vgw
  subnet_id = module.vnet.subnet_id
}

module "vgw_On" {
  source = "./network/vgw/vgw"
  resource_group_name = module.resource_group2.name
  location = module.resource_group2.location
  vgw = local.gateway_On.vgw
  subnet_id = module.vnet_On.subnet_id
}


module "lgw" {
  source = "./network/vgw/lgw"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  lgw = local.gateway.lgw
  subnet_id = module.vnet.subnet_id
  public_ip = module.vgw_On.pip
}


module "lgw_On" {
  source = "./network/vgw/lgw"
  resource_group_name = module.resource_group2.name
  location = module.resource_group2.location
  lgw = local.gateway_On.lgw
  subnet_id = module.vnet_On.subnet_id
  public_ip = module.vgw.pip
}



module "vgw_conn" {
  source = "./network/vgw/vgw_conn"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  vgw_conn = local.gateway.vgw_conn
  vgw_id = module.vgw.id
  lgw_id = module.lgw.id
}


module "vgw_conn_On" {
  source = "./network/vgw/vgw_conn"
  resource_group_name = module.resource_group2.name
  location = module.resource_group2.location
  vgw_conn = local.gateway_On.vgw_conn
  vgw_id = module.vgw_On.id
  lgw_id = module.lgw_On.id
}

module "data_disk_create" {
   source = "./vm/disk/data_disk"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  disks = local.vm.data_disks_create
}

# module "data_disk_attach" {
#    source = "./vm/disk/data_disk_attach"

#   resource_group_name = module.resource_group.name
#   location = module.resource_group.location
#   disks = local.vm.data_disks_attach
#   data_disk_id = module.data_disk_create.id
#   vm_id = module.vm.id
# }

# module "bastion" {
#   source = "./network/conn/bastion"

#   resource_group_name = module.resource_group.name
#   location = module.resource_group.location
#   bastion = local.bastion.bastion
#   subnet_id = module.vnet.subnet_id
#   pip_id = module.pip.id
# }

# module "jumpbox" {
#   source = "./network/conn/jumpbox"

#   resource_group_name = module.resource_group.name
#   location = module.resource_group.location
#   nic_id = module.nic.id
#   avset_id = module.avset.id
#   admin_username = "azureuser"
#   admin_password = "Azurexptmxm123"
#   jumpbox = local.jumpbox.vms
# }


output "avset_id" {
  value = module.avset.id
}

output "lb_ext_id" {
  value = module.lb.id
}

output "lb_ext_backendpool_id" {
  value = module.lb.backendpool_id
}


output "nic_id" {
  value = module.nic.id
}

output "nsg_id" {
  value = module.nsg.id
}

output "nsg_subnet_set_info" {
  value = module.nsg_subnet_set.info
}

# output "pip_id" {
#   value = module.pip.id
# }

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

output "storage_id" {
  value = module.storage.id
}
output "storage_name" {
  value = module.storage.storagename
}

# output "storage_file_share_name" {
#   value = module.storage.filesharename
# }

output "data_disk_id" {
  value = module.data_disk.id
}

output "data_disk_create_id" {
  value = module.data_disk_create.id
}

# output "data_disk_attach_info" {
#   value = module.data_disk_attach.info
# }




