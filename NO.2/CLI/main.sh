#!/bin/sh

# 자원명
RgName="Hands-On-2-RG"
Location="eastus"
Vnet01Name="Hands-On-2-VNet01"
Subnet01Name="Hands-On-2-Subnet01"
NSG01Name="Hands-On-2-NSG01"
ELB01Name="Hands-On-2-ELB01"
ELB01PIP="ELB01PIP"
ELB01BkPool01="ELB01BackPool01"
ELB01HTTPProbe="Health80Probe"
ELB01NAT01="VM01RDP"
ELB01NAT02="VM02RDP"
VMSSName="Hands-On-2-VMSS"
VM01Name="Hands-On-2-VM01"
VM01Nic="Hands-On-2-VM01VMNic"
VM01ipconfig="ipconfigHands-On-2-VM01"
VM02Name="Hands-On-2-VM02"
VM02Nic="Hands-On-2-VM02VMNic"
VM02ipconfig="ipconfigHands-On-2-VM02"
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


#ELB PIP 생성
az network public-ip create \
    --resource-group $RgName \
    --name $ELB01PIP \
    --sku Standard \
    --zone 1

#VMSS 생성
az vmss create \
	--name $VMSSName \
	-g $RgName \
	--lb $ELB01Name \
	--vnet-name $Vnet01Name \
	--subnet $Subnet01Name \
	--admin-username azureuser \
	--admin-password $Pw \
	--image win2016datacenter \
	--public-ip-address $ELB01PIP \
	--backend-pool-name $ELB01BkPool01 \
	--lb-nat-pool-name "ELB01VMSSNAT" \
	--lb-sku Standard \
	--nsg $NSG01Name
#lb-nat-pool-name 옵션은 vmss 생성 시 새로 생성하는 LB에만 적용가능하다.
#vmss 신규 생성 시 기존 LB를 연결할 때는 --lb-nat-pool-name을 사용할 수 없다.
#위 사유 때문에 VMSS Hands-On의 경우 ELB보다 VMSS를 먼저 만든다.

#ELB 상태 프로브 만들기
az network lb probe create \
    --resource-group $RgName \
    --lb-name $ELB01Name \
    --name $ELB01HTTPProbe \
    --protocol tcp \
    --port 80


#ELB 부하 분산 규칙 생성
az network lb rule update \
    --resource-group $RgName \
    --lb-name $ELB01Name \
    --name LBRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name LoadBalancerFrontEnd \
    --backend-pool-name $ELB01BkPool01 \
    --probe-name $ELB01HTTPProbe \
    --idle-timeout 4


#VMSS에 IIS 설치
az vmss extension set \
	--publisher Microsoft.Compute \
	--version 1.8 \
	--name CustomScriptExtension \
	--vmss-name $VMSSName \
	--resource-group $RgName \
	--settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
#VM과는 다르게 정상 설치가 안됨
#해결
# VM에 RDP 통해 들어가서 PowerShell 연 후 아래 명령어 입력
#Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)
# 

#VMSS 인스턴스 보기
az vmss list-instances \
  --resource-group Hands-On-2-RG \
  --name Hands-On-2-VMSS \
  --output table

#연결 정보 나열
az vmss list-instance-connection-info \
  --resource-group Hands-On-2-RG \
  --name Hands-On-2-VMSS

#접속 확인
# mstsc ELB Public IP:30001
# ID=azureuser
# PW=Azurexptmxm123

