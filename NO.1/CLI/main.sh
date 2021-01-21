```bash

#!/bin/sh

# 자원명
RgName="Hands-On-1-RG"
Location="eastus"
Vnet01Name="Hands-On-1-VNet01"
Subnet01Name="Hands-On-1-Subnet01"
NSG01Name="Hands-On-1-NSG01"
ELB01Name="Hands-On-1-ELB01"
ELB01PIP="ELB01PIP"
ELB01BkPool01="ELB01BackPool01"
ELB01HTTPProbe="Health80Probe"
ELB01NAT01="VM01RDP"
ELB01NAT02="VM02RDP"
VM01Name="Hands-On-1-VM01"
VM01Nic="Hands-On-1-VM01VMNic"
VM01ipconfig="ipconfigHands-On-1-VM01"
VM02Name="Hands-On-1-VM02"
VM02Nic="Hands-On-1-VM02VMNic"
VM02ipconfig="ipconfigHands-On-1-VM02"
VMAvSet01Name="AvSet01"
VM01IP="10.1.0.4"
VM02IP="10.1.0.5"
Pw="Azurexptmxm123"

#윈도우 환경에서는 줄내림을 \ 가 아닌 `로 해야함
az group create \
--name $RgName \
--location $Location


az network vnet create \
  --name $Vnet01Name \
  --resource-group $RgName \
  --location $Location \
  --address-prefix 10.0.0.0/8 \
  --subnet-name $Subnet01Name \
  --subnet-prefix 10.1.0.0/16


az network nsg create \
  --resource-group $RgName \
  --name $NSG01Name \
  --location $Location


#NSG 80 Allow Rule 생성
az network nsg rule create \
  --resource-group $RgName \
  --nsg-name $NSG01Name \
  --name Allow-HTTP-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefix Internet \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range 80


#NSG 22 Allow Rule 생성
az network nsg rule create \
  --resource-group $RgName \
  --nsg-name $NSG01Name \
  --name Allow-SSH-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 150 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range 22


#NSG 3389 Allow Rule 생성
az network nsg rule create \
  --resource-group $RgName \
  --nsg-name $NSG01Name \
  --name Allow-RDP-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 250 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range 3389


#NSG 규칙 Vnet, Subnet에 연결
az network vnet subnet update \
  --vnet-name $Vnet01Name \
  --name $Subnet01Name \
  --resource-group $RgName \
  --network-security-group $NSG01Name


#VM AvSet 생성
az vm availability-set create \
	-n $VMAvSet01Name \
	-g $RgName \
	--platform-fault-domain-count 2 \
	--platform-update-domain-count 5


#VM 만들기
az vm create \
	--resource-group $RgName \
	--location $Location \
	--name $VM01Name \
	--vnet-name $Vnet01Name \
	--subnet $Subnet01Name \
	--nsg $NSG01Name \
	--private-ip-address $VM01IP \
	--public-ip-sku Standard \
	--public-ip-address-allocation static \
	--availability-set $VMAvSet01Name \
	--image win2016datacenter \
	--admin-username azureuser \
	--admin-password $Pw \
	--no-wait


az vm create \
	--resource-group $RgName \
	--location $Location \
	--name $VM02Name \
	--vnet-name $Vnet01Name \
	--subnet $Subnet01Name \
	--nsg $NSG01Name \
	--private-ip-address $VM02IP \
	--public-ip-sku Standard \
	--public-ip-address-allocation static \
	--availability-set $VMAvSet01Name \
	--image win2016datacenter \
	--admin-username azureuser \
	--admin-password $Pw \
	--no-wait


#ELB PIP 생성
az network public-ip create \
    --resource-group $RgName \
    --name $ELB01PIP \
    --sku Standard \
    --zone 1


#ELB 생성
az network lb create \
    --resource-group $RgName \
    --name $ELB01Name \
    --sku Standard \
    --public-ip-address $ELB01PIP \
    --backend-pool-name $ELB01BkPool01


#ELB 상태 프로브 만들기
az network lb probe create \
    --resource-group $RgName \
    --lb-name $ELB01Name \
    --name $ELB01HTTPProbe \
    --protocol tcp \
    --port 80


#ELB 백엔드 풀에 VM 추가
az network nic ip-config address-pool add \
    --resource-group $RgName \
    --nic-name $VM01Nic \
    --ip-config-name $VM01ipconfig \
    --lb-name $ELB01Name \
    --address-pool $ELB01BkPool01


az network nic ip-config address-pool add \
    --resource-group $RgName \
    --nic-name $VM02Nic \
    --ip-config-name $VM02ipconfig \
    --lb-name $ELB01Name \
    --address-pool $ELB01BkPool01


#ELB 부하 분산 규칙 생성
az network lb rule create \
    --resource-group $RgName \
    --lb-name $ELB01Name \
    --name HTTPRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name LoadBalancerFrontEnd \
    --backend-pool-name $ELB01BkPool01 \
    --probe-name $ELB01HTTPProbe \
    --idle-timeout 15


#ELB 인바운드 NAT 규칙 생성
az network lb inbound-nat-rule create \
	--resource-group $RgName \
	--frontend-ip-name LoadBalancerFrontEnd \
	--lb-name $ELB01Name \
	--name $ELB01NAT01 \
	--protocol Tcp \
	--frontend-port 30001 \
	--backend-port 3389


az network lb inbound-nat-rule create \
	--resource-group $RgName \
	--frontend-ip-name LoadBalancerFrontEnd \
	--lb-name $ELB01Name \
	--name $ELB01NAT02 \
	--protocol Tcp \
	--frontend-port 30002 \
	--backend-port 3389


#ELB 인바운드 NAT 규칙 설정
az network nic ip-config inbound-nat-rule add \
	--resource-group $RgName \
	--nic-name $VM01Nic \
	--ip-config-name $VM01ipconfig \
	--lb-name $ELB01Name \
	--inbound-nat-rule $ELB01NAT01


az network nic ip-config inbound-nat-rule add \
	--resource-group $RgName \
	--nic-name $VM02Nic \
	--ip-config-name $VM02ipconfig \
	--lb-name $ELB01Name \
	--inbound-nat-rule $ELB01NAT02


# 현재 제대로 적용 안됨.backendIpConfigurations 에 값이 들어가야함
#az network lb address-pool address add \
#	-g $RgName \
#	--lb-name $ELB01Name \
#	--pool-name $ELB01BkPool01 \
#	-n $ELB01PIP \
#	--vnet $Vnet01Name \
#	--ip-address $VM01IP

#VM에 IIS 설치
# 아래 명령어 입력 시 에러 발생
# 에러 문구 : Expecting property name enclosed in double quotes: line 1 column 2 (char 1)
# 이에 따라 Windows 환경이 아닌 Linux 환경에서 작업 진행함
# 환경 전환 : Windows 10 -> Azure Cloud Shell(Bash)
az vm extension set \
	--publisher Microsoft.Compute \
	--version 1.8 \
	--name CustomScriptExtension \
	--vm-name $VM01Name \
	--resource-group $RgName \
	--settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


az vm extension set \
	--publisher Microsoft.Compute \
	--version 1.8 \
	--name CustomScriptExtension \
	--vm-name $VM02Name \
	--resource-group $RgName \
	--settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


#ELB Public IP 확인
az network public-ip show \
	-g $RgName \
	-n $ELB01PIP \
	--query [ipAddress] \
	-o tsv

#접속 확인
# mstsc ELB Public IP:30001
# ID=azureuser
# PW=Azurexptmxm123

```
