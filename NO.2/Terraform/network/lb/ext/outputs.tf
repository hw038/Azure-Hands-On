output "id" {
  value = local.lb_id
}

output "backendpool_id" {
    value = local.backendpool_id
}

output "backendpool_id2" {
    value = local.backendpool_id2
}

# output "backend_address_pool_id" {
#   value = local.backend_address_pool_id
# }
# output "backend_ip_configuration_ids" {
#   value = data.azurerm_lb_backend_address_pool.beap.backend_ip_configurations.*.id
# }
