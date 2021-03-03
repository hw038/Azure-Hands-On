
# 목표
- terraform의 module을 최대한 사용하여 프로젝트 진행
- 여러가지 타입의 variable(list, map ..etc)을 활용하여 lookup 함수를 통해 확인된 id값 사용
   
## 특이사항
- LB - VM 간 연결과는 다르게 VMSS 생성 시에 연관된 lb의 backend_pool, nat_rule을 id로 연결해야 한다.
- VMSS Extension의 경우 Linux와 Windows Server에 따라 publisher와 type을 변경해야 한다.

```
Linux
-----------------------------------------------------------------------------------------
publisher                       = "Microsoft.Azure.Extensions"
  type                            = "CustomScript"
  type_handler_version            = "2.0"
  settings = jsonencode({
    "commandToExecute" = "apt-get -y update && apt-get -y install nginx && hostname > /var/www/html/index.html"
  })
-----------------------------------------------------------------------------------------
Windows Server
-----------------------------------------------------------------------------------------
publisher                       = "Microsoft.Compute"
  type                            = "CustomScriptExtension"
  type_handler_version            = "1.8"
  settings = jsonencode({
        "commandToExecute" = "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
  })
-----------------------------------------------------------------------------------------
```
