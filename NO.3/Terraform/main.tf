locals {
  resource_group = "Hands-On-No.3"
  location = "eastus"

  storage = {
    storages = [ 
      ["no3storagehh", "S", "LRS"],
    ]
    file_share = [
      ["no3fileshare","50"],
    ]
  }

  

  nsg = {
    nsg_names = ["NO.3-NSG01","NO.3-NSG02"] 
    nsg_rules = [ 
      ["NO.3-NSG01", 100, "port-tcp-22", 22, "*", "tcp"],
      ["NO.3-NSG01", 110, "port-tcp-80", 80, "*", "tcp"],
      ["NO.3-NSG02", 100, "port-tcp-22", 22, "*", "tcp"],
      ["NO.3-NSG02", 110, "port-tcp-80", 80, "*", "tcp"],
    ],
    nsg_subnet_set = [
      ["NO.3-Subnet01", "NO.3-NSG01"],
      ["NO.3-Subnet02", "NO.3-NSG02"]
    ]     
  }

  vnet = {
    address_space = ["10.0.0.0/8"]
    subnets = [
      ["NO.3-Subnet01", "10.1.0.0/16"],
      ["NO.3-Subnet02", "10.2.0.0/16"],
      ["AzureBastionSubnet", "10.100.0.0/24"],
      ["Jumpbox-Subnet", "10.200.0.0/24"],
    ] 
  }

  lb = {
    lbs = [
      ["NO.3-LB-EXT","S", "S"]
    ]  
    probes = [
      ["NO.3-LB-EXT", "probe-http-80", "http", 80, "/"]
    ] 
    rules = [
      ["NO.3-LB-EXT", "rule-http-80","tcp",80,80, "probe-http-80"]
    ] 
    nat = [
      ["NO.3-LB-EXT", "","tcp",30001,30010,3389]
    ]
  }

  lb_int = {
    lbs = [
      ["NO.3-LB-INT","NO.3-Subnet02", "S", "10.2.0.10"]
    ]  

    probes = [
      ["NO.3-LB-INT", "probe-http-80", "http", 80, "/"]
    ] 
    rules = [
      ["NO.3-LB-INT", "rule-http-80","tcp",80,80, "probe-http-80"]
    ] 
    
}

avset_names = ["NO.3-AVset01", "NO.3-AVset02"]

bastion = {
  bastion = [
    ["NO.3-Bastion","10.100.0.0/24","AzureBastionSubnet","NO.3-Bastion-pip"]
  ],
}

jumpbox = {
  vms=[
      ["vm-jumpbox", ["jumpbox-nic-ext"], "Standard_F2s", "",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "", ["tag", "Jumpbox"]],
  ]
}

vm = {
    public_ips = [
      ["NO.3-Jumpbox-pip", "S", "S"],
      ["NO.3-Bastion-pip", "S", "S"]
    ],
    nics = [
      ["vm-test-01-nic-ext", "NO.3-Subnet01", "S","10.1.0.11", "","false"],
      ["vm-test-02-nic-ext", "NO.3-Subnet01", "S","10.1.0.12", "","false"],
      ["vm-test-03-nic-int", "NO.3-Subnet02", "S","10.2.0.11", "", "false"],
      ["vm-test-04-nic-int", "NO.3-Subnet02", "S","10.2.0.12", "", "false"],      
      ["jumpbox-nic-ext", "Jumpbox-Subnet", "S","10.200.0.11", "", "false"],      
    ],     
    vms=[
      ["vm-test-01", ["vm-test-01-nic-ext"], "Standard_F2s", "NO.3-AVset01",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "no3storagehh", ["tag", "tag1"]],
      ["vm-test-02", ["vm-test-02-nic-ext"], "Standard_F2s", "NO.3-AVset01",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "no3storagehh", ["tag", "tag2"]],
      ["vm-test-03", ["vm-test-03-nic-int"], "Standard_F2s", "NO.3-AVset02",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "no3storagehh", ["tag", "tag2"]],
      ["vm-test-04", ["vm-test-04-nic-int"], "Standard_F2s", "NO.3-AVset02",["Canonical","UbuntuServer","16.04-LTS","latest"], ["P", 32], "no3storagehh", ["tag", "tag2"]],
    ],
    data_disks=[
      ["vm-test-01", 0, "vm-test-01-disk-data-0", "H", 32, "ReadWrite"],
      ["vm-test-02", 0, "vm-test-02-disk-data-0", "H", 32, "ReadWrite"],
      ["vm-test-03", 0, "vm-test-03-disk-data-0", "H", 32, "ReadWrite"],
      ["vm-test-04", 0, "vm-test-04-disk-data-0", "H", 32, "ReadWrite"]
    ],
    data_disks_create=[
      ["vm-test-01-disk-data-1", "H", 32], 
      ["vm-test-02-disk-data-1", "H", 32], 
      ["vm-test-03-disk-data-1", "H", 32], 
      ["vm-test-04-disk-data-1", "H", 32]        
    ],
    data_disks_attach=[                                                  
      ["vm-test-01", 1, "vm-test-01-disk-data-1", "ReadWrite"],
      ["vm-test-02", 1, "vm-test-02-disk-data-1", "ReadWrite"],
      ["vm-test-03", 1, "vm-test-03-disk-data-1", "ReadWrite"],
      ["vm-test-04", 1, "vm-test-04-disk-data-1", "ReadWrite"] 
    ],

    nic_backend_pool_set=[
      ["NO.3-LB-EXT", "vm-test-01-nic-ext"],
      ["NO.3-LB-EXT", "vm-test-02-nic-ext"],
    ],
    nic_int_backend_pool_set=[
      ["NO.3-LB-INT", "vm-test-03-nic-int"],
      ["NO.3-LB-INT", "vm-test-04-nic-int"],
    ],
    extension=[
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update && apt-get -y install nginx && hostname > /var/www/html/index.html"],
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update && apt-get -y install nginx && hostname > /var/www/html/index.html"],
      ["mount","Microsoft.Azure.Extensions","CustomScript","2.0","sudo mkdir /mnt/${module.storage.filesharename}; sudo mkdir /etc/smbcredentials; sudo bash -c 'echo -e \"username=${module.storage.storagename}\\npassword=${module.storage.fspw}\" > /etc/smbcredentials/${module.storage.storagename}.cred';sudo chmod 600 /etc/smbcredentials/${module.storage.storagename}.cred;sudo mount -t cifs //${module.storage.storagename}.file.core.windows.net/${module.storage.filesharename} /mnt/${module.storage.filesharename} -o vers=3.0,credentials=/etc/smbcredentials/${module.storage.storagename}.cred,dir_mode=0777,file_mode=0777,serverino; sudo bash -c 'echo \"//${module.storage.storagename}.file.core.windows.net/${module.storage.filesharename} /mnt/${module.storage.filesharename} cifs nofail,vers=3.0,credentials=/etc/smbcredentials/${module.storage.storagename}.cred,dir_mode=0777,file_mode=0777,serverino\" >> /etc/fstab'"],
      ["mount","Microsoft.Azure.Extensions","CustomScript","2.0","sudo mkdir /mnt/${module.storage.filesharename}; sudo mkdir /etc/smbcredentials; sudo bash -c 'echo -e \"username=${module.storage.storagename}\\npassword=${module.storage.fspw}\" > /etc/smbcredentials/${module.storage.storagename}.cred';sudo chmod 600 /etc/smbcredentials/${module.storage.storagename}.cred;sudo mount -t cifs //${module.storage.storagename}.file.core.windows.net/${module.storage.filesharename} /mnt/${module.storage.filesharename} -o vers=3.0,credentials=/etc/smbcredentials/${module.storage.storagename}.cred,dir_mode=0777,file_mode=0777,serverino; sudo bash -c 'echo \"//${module.storage.storagename}.file.core.windows.net/${module.storage.filesharename} /mnt/${module.storage.filesharename} cifs nofail,vers=3.0,credentials=/etc/smbcredentials/${module.storage.storagename}.cred,dir_mode=0777,file_mode=0777,serverino\" >> /etc/fstab'"],
    ]
  }
}

module "resource_group" {
  source = "./resource_group"  
  name = local.resource_group
  location = local.location
}

module "storage" {
  source = "./storage"
  
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  storages = local.storage.storages
  fileshare = local.storage.file_share
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
  vnet_name = "NO.3-VNet01"      
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

module "lb_int" {
  source = "./network/lb/int"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  subnet_id = module.vnet.subnet_id
  lbs = local.lb_int.lbs
  probes = local.lb_int.probes
  rules = local.lb_int.rules
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
  public_ips = local.vm.public_ips
}

module "nic" {
  source = "./network/nic/nic"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  subnet_id = module.vnet.subnet_id
  pip_id = module.pip.id
  nics = local.vm.nics
}

module "nic_ext_backendpool_set" {
  source = "./network/nic/nic_backendpool_set"

  nic_id = module.nic.id
  lb_backendpool_id = module.lb.backendpool_id
  nic_backend_pool_set = local.vm.nic_backend_pool_set
}

module "nic_int_backendpool_set" {
  source = "./network/nic/nic_backendpool_set"

  nic_id = module.nic.id
  lb_backendpool_id = module.lb_int.backendpool_id
  nic_backend_pool_set = local.vm.nic_int_backend_pool_set
}

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

module "data_disk_create" {
   source = "./vm/disk/data_disk"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  disks = local.vm.data_disks_create
}

module "data_disk_attach" {
   source = "./vm/disk/data_disk_attach"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  disks = local.vm.data_disks_attach
  data_disk_id = module.data_disk_create.id
  vm_id = module.vm.id
}

module "bastion" {
  source = "./network/conn/bastion"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  bastion = local.bastion.bastion
  subnet_id = module.vnet.subnet_id
  pip_id = module.pip.id
}

module "jumpbox" {
  source = "./network/conn/jumpbox"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  nic_id = module.nic.id
  avset_id = module.avset.id
  admin_username = "azureuser"
  admin_password = "Azurexptmxm123"
  jumpbox = local.jumpbox.vms
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


output "nic_id" {
  value = module.nic.id
}

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

output "storage_id" {
  value = module.storage.id
}
output "storage_name" {
  value = module.storage.storagename
}

output "storage_file_share_name" {
  value = module.storage.filesharename
}

output "data_disk_id" {
  value = module.data_disk.id
}

output "data_disk_create_id" {
  value = module.data_disk_create.id
}

output "data_disk_attach_info" {
  value = module.data_disk_attach.info
}




