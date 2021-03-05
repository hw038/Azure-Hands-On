variable "resource_group_name" { default = "" }
variable "location" { default = "" }
variable "public_ip" { default = {} }
variable "subnet_id" { default = {} }
variable "lgw" {default = [[]]}

# resource_group_name = module.resource_group.name                  # respurce group name
# location = module.resource_group.location                         # location
# subnet_id = module.vnet.subnet_id                                 # subnet_id : subnet_id list
# lbs=[                                                             # lbs : lb list (2-D array)
#   ["lb-test-01", "subnet1", "D", "10.0.0.5"]                      # [ ["lb name", "subnet name", "private ip type(static : S, dymanic : D)", "private ip address"] ]
# ]  
# probes=[                                                          # probes : probe list (2-D array)
#   ["lb-test-01", "probe-http-80", "http", 80, "/"],               # [ ["lb name", "probe name", "protocol type", port, "request_path"] ]
#   ["lb-test-01", "probe-tcp-22", "tcp", 22, "/"]
# ] 
# rules=[                                                           # rules : rule list (2-D array)
#   ["lb-test-01", "rule-http-80","tcp",80,80,"probe-http-80"]      # [ ["lb name", "rule name", "protocol type", frontend_port, backend_port, "probe name"] ]
# ] 