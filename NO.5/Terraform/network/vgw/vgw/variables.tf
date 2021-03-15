variable "resource_group_name" { default = "" }
variable "location" { default = "" }
variable "subnet_id" { default = {} }
variable "public_id" { default = {} }
variable "vgw" {default = [[]]}

# resource_group_name = module.resource_group.name                  # respurce group name
# location = module.resource_group.location                         # location
# subnet_id = module.vnet.subnet_id                                 # subnet_id : subnet_id list
# vgw = [
#       ["${module.resource_group.name}","${module.resource_group.location}","NO.5-VGW","10.100.100.0/24","20.0.0.0/16","VGW-PIP","NO.5-VNet01","NO.5-Subnet01","GatewaySubnet"],
#     ]
# probes=[                                                          # probes : probe list (2-D array)
#   ["lb-test-01", "probe-http-80", "http", 80, "/"],               # [ ["lb name", "probe name", "protocol type", port, "request_path"] ]
#   ["lb-test-01", "probe-tcp-22", "tcp", 22, "/"]
# ] 
# rules=[                                                           # rules : rule list (2-D array)
#   ["lb-test-01", "rule-http-80","tcp",80,80,"probe-http-80"]      # [ ["lb name", "rule name", "protocol type", frontend_port, backend_port, "probe name"] ]
# ] 