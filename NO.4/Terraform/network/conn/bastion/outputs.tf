output "id" {
    description = "생성된 모든 bastion 정보를 name: id 형태로 전달"

    value = {
        for bastion in azurerm_bastion_host.tfmodule:
        bastion.name => bastion.id
    }
}