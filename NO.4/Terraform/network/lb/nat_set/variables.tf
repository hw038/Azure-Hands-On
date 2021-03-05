variable "resource_group_name" { default = "" }
variable "location" { default = "" }
variable "nic_id" {default = {}}
variable "nic_ip_config_name" {default = {}}
variable "nat_rule_id" {default = {}}
variable "nat_set" {default = [[]]}


# resource_group_name = module.resource_group.name                  # respurce group name
# location = module.resource_group.location                         # location
# lbs=[                                                             # lbs : lb list (2-D array)
#   ["lb-test-01","B", "D"]                                         # [ ["lb name", "lb sku(basic : B, standard : S)", "public ip type(static : S, dymanic : D)"] ]
# ]  
# probes=[                                                          # probes : probe list (2-D array)
#   ["lb-test-01", "probe-http-80", "http", 80, "/"],               # [ ["lb name", "probe name", "protocol type", port, "request_path"] ]
#   ["lb-test-01", "probe-tcp-22", "tcp", 22, "/"]
# ] 
# rules=[                                                           # rules : rule list (2-D array)
#   ["lb-test-01", "rule-http-80","tcp",80,80,"probe-http-80"]      # [ ["lb name", "rule name", "protocol type", frontend_port, backend_port, "probe name"] ]
# ] 