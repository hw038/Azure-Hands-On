variable "resource_group_name" { default = "" }
variable "location" { default = "" }
variable "vgw_id" { default = {} }
variable "lgw_id" { default = {} }
variable "vgw_conn" {default = [[]]}

# resource_group_name = module.resource_group.name                  # respurce group name
# location = module.resource_group.location                         # location
# subnet_id = module.vnet.subnet_id                                 # subnet_id : subnet_id list
# vgw_conn = [
#       ["${module.resource_group2.name}","${module.resource_group2.location}","NO.5-VGW-Onprem","NO.5-LGW-Onprem","NO.5-VGW-On-Conn","xptmxm123"],
#     ]