output "id" {
  value = local.lb_id
}

output "backendpool_id" {
    value = local.backendpool_id
}

output "backendpool_id2" {
    value = local.backendpool_id2
}

output "nat_rule_id" {
    description = "생성된 모든 nat_rule 정보를 name: id 형태로 전달"

    value = {
        for nat_rule in azurerm_lb_nat_rule.tfmodule:
        nat_rule.name => nat_rule.id
    }
}



# output "natpool_id" {
#     value = local.natpool_id
# }