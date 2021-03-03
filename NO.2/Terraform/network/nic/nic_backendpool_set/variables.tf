variable "nic_backend_pool_set" { default = [[]] }
variable "nic_id" { default = {} }
variable "lb_backendpool_id" { default = {} }
variable "vmss_ipconf" { default = {} }

# nic_id = module.nic.id                            # nic_id : nic_id list
# lb_backendpool_id = module.lb.backendpool_id      # lb_backendpool_id : lb_backendpool_id list
# nic_backend_pool_set=[                            # nic_backend_pool_set : lb backend pool & nic connect list (2-D array)
#   ["lb-test-01", "test-nic-01"],                  # [ [ "lb name", "nic name" ] ]
#   ["lb-test-01", "test-nic-02"]
# ]  