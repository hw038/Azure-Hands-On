variable "resource_group_name" { default = "" }
variable "location" { default = "" }
variable "public_ip" { default = {} }
variable "subnet_id" { default = {} }
variable "lgw" {default = [[]]}

# resource_group_name = module.resource_group.name                  # respurce group name
# location = module.resource_group.location                         # location
# subnet_id = module.vnet.subnet_id                                 # subnet_id : subnet_id list
# lgw = [
#       ["${module.resource_group.name}","${module.resource_group.location}","NO.5-LGW","20.0.0.0/16","VGW-Onprem-PIP","NO.5-VNet01"],
#     ]
# probes=[                                                          # probes : probe list (2-D array)
#   ["lb-test-01", "probe-http-80", "http", 80, "/"],               # [ ["lb name", "probe name", "protocol type", port, "request_path"] ]
#   ["lb-test-01", "probe-tcp-22", "tcp", 22, "/"]
# ] 
# rules=[                                                           # rules : rule list (2-D array)
#   ["lb-test-01", "rule-http-80","tcp",80,80,"probe-http-80"]      # [ ["lb name", "rule name", "protocol type", frontend_port, backend_port, "probe name"] ]
# ] 