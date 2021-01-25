#!/bin/sh

# 자원명
RgName="Hands-On-3-RG"
Location="eastus"
StAccName="handson3storage"
FileShareName="handson3fs"
Fileurl=".file.core.windows.net"
Vnet01Name="Hands-On-3-VNet01"
Vnet02Name="Hands-On-3-VNet02"
Subnet01Name="Hands-On-3-Subnet01"
Subnet02Name="Hands-On-3-Subnet02"
BastionSubnet="AzureBastionSubnet"
BastionPIP="Hands-On-3-BastionPIP"
NSG01Name="Hands-On-3-NSG01"
NSG02Name="Hands-On-3-NSG02"
NSGJMP="Hands-On-3-JMP"
VMAvSet01Name="AvSet01"
VMAvSet02Name="AvSet02"
ELB01Name="Hands-On-3-ELB01"
ELB01PIP="ELB01PIP"
ELB01BkPool01="ELB01BackPool01"
ELB01HTTPProbe="Health80Probe"
ELB01NAT01="VM01RDP"
ELB01NAT02="VM02RDP"
VMJump01="Hands-On-3-JBox"
VM01Name="Hands-On-3-VM01"
VM01Nic="Hands-On-3-VM01VMNic"
VM01ipconfig="ipconfigHands-On-3-VM01"
VM02Name="Hands-On-3-VM02"
VM02Nic="Hands-On-3-VM02VMNic"
VM02ipconfig="ipconfigHands-On-3-VM02"
VM01IP="10.1.0.4"
VM02IP="10.1.0.5"
JMPPIP="JumpBoxPIP"
JMPSubnet="Hands-On-3-JBoxSubnet"
ILB01Name="Hands-On-3-ILB01"
ILB01PIP="ILB01PIP"
ILB01BkPool01="ILB01BackPool01"
ILB01DBProbe="Health3306Probe"
ILB01NAT01="VM03RDP"
ILB01NAT02="VM04RDP"
VM03Name="Hands-On-3-VM03"
VM03Nic="Hands-On-3-VM03VMNic"
VM03ipconfig="ipconfigHands-On-3-VM03"
VM04Name="Hands-On-3-VM04"
VM04Nic="Hands-On-3-VM04VMNic"
VM04ipconfig="ipconfigHands-On-3-VM04"
VM03IP="10.2.0.4"
VM04IP="10.2.0.5"
ILB01IP="10.2.0.10"
ID="azureuser"
PW="Azurexptmxm123"

az group create --name $RgName --location $Location

#스토리지 계정 및 File Share 생성
az storage account create -n $StAccName -g $RgName
az storage share create -n $FileShareName --account-name $StAccName --quota 100

#스토리지 access key 저장
export keys=$(az storage account keys list --resource-group $RgName --account-name $StAccName --query "[0].value" | tr -d '"')

az network vnet create --name $Vnet01Name -g $RgName --location $Location --address-prefix 10.0.0.0/8

az network vnet subnet create --address-prefixes 10.0.0.0/24 --name $JMPSubnet -g $RgName --vnet-name $Vnet01Name
az network vnet subnet create --address-prefixes 10.1.0.0/16 --name $Subnet01Name -g $RgName --vnet-name $Vnet01Name
az network vnet subnet create --address-prefixes 10.2.0.0/16 --name $Subnet02Name -g $RgName --vnet-name $Vnet01Name
az network vnet subnet create --address-prefixes 10.100.100.0/24 --name $BastionSubnet -g $RgName --vnet-name $Vnet01Name


az network nsg create -g $RgName --n $NSG01Name --location $Location
az network nsg create -g $RgName --n $NSG02Name --location $Location
az network nsg create -g $RgName --n $NSGJMP --location $Location


#NSG 80, 22, 3389 Allow Rule 생성
az network nsg rule create -g $RgName --nsg-name $NSG01Name --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range 80
az network nsg rule create -g $RgName --nsg-name $NSG01Name --name Allow-SSH-All --access Allow --protocol Tcp --direction Inbound --priority 150 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22
az network nsg rule create -g $RgName --nsg-name $NSG01Name --name Allow-RDP-All --access Allow --protocol Tcp --direction Inbound --priority 250 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3389

#NSG 규칙 Vnet, Subnet에 연결
az network vnet subnet update --vnet-name $Vnet01Name --name $Subnet01Name -g $RgName --network-security-group $NSG01Name

az network nsg rule create -g $RgName --nsg-name $NSG02Name --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range 80
az network nsg rule create -g $RgName --nsg-name $NSG02Name --name Allow-SSH-All --access Allow --protocol Tcp --direction Inbound --priority 150 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22
az network nsg rule create -g $RgName --nsg-name $NSG02Name --name Allow-RDP-All --access Allow --protocol Tcp --direction Inbound --priority 250 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3389

az network vnet subnet update --vnet-name $Vnet01Name --name $Subnet02Name -g $RgName --network-security-group $NSG02Name

$JumpBox NSG 규칙 생성 및 연결

az network nsg rule create -g $RgName --nsg-name $NSGJMP --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range 80
az network nsg rule create -g $RgName --nsg-name $NSGJMP --name Allow-SSH-All --access Allow --protocol Tcp --direction Inbound --priority 150 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22
az network nsg rule create -g $RgName --nsg-name $NSGJMP --name Allow-RDP-All --access Allow --protocol Tcp --direction Inbound --priority 250 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3389

az network vnet subnet update --vnet-name $Vnet01Name --name $JMPSubnet -g $RgName --network-security-group $NSGJMP


#VM AvSet 생성
az vm availability-set create -n $VMAvSet01Name -g $RgName --platform-fault-domain-count 2 --platform-update-domain-count 5
az vm availability-set create -n $VMAvSet02Name	-g $RgName --platform-fault-domain-count 2 --platform-update-domain-count 5

#VM 생성
az vm create -g $RgName --location $Location --name $VM01Name --vnet-name $Vnet01Name --subnet $Subnet01Name --nsg $NSG01Name --public-ip-address "" --private-ip-address $VM01IP --public-ip-sku Standard --public-ip-address-allocation static --availability-set $VMAvSet01Name --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait
az vm create -g $RgName --location $Location --name $VM02Name --vnet-name $Vnet01Name --subnet $Subnet01Name --nsg $NSG01Name --public-ip-address "" --private-ip-address $VM02IP --public-ip-sku Standard --public-ip-address-allocation static --availability-set $VMAvSet01Name --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait
az vm create -g $RgName --location $Location --name $VM03Name --vnet-name $Vnet01Name --subnet $Subnet02Name --nsg $NSG02Name --public-ip-address "" --private-ip-address $VM03IP --public-ip-sku Standard --public-ip-address-allocation static --availability-set $VMAvSet02Name --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait
az vm create -g $RgName --location $Location --name $VM04Name --vnet-name $Vnet01Name --subnet $Subnet02Name --nsg $NSG02Name --public-ip-address "" --private-ip-address $VM04IP --public-ip-sku Standard --public-ip-address-allocation static --availability-set $VMAvSet02Name --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait


#ELB PIP 생성
az network public-ip create -g $RgName --name $ELB01PIP --sku Standard --zone 1
az network public-ip create -g $RgName --name $BastionPIP --sku Standard --zone 1
az network public-ip create -g $RgName --name $JMPPIP --sku Standard

#JumpBox 생성
az vm create -g $RgName --location $Location --name $VMJump01 --vnet-name $Vnet01Name --public-ip-address $JMPPIP --public-ip-sku Standard --public-ip-address-allocation static --image win2016datacenter --nsg "" --admin-username azureuser --admin-password $PW --no-wait


#Bastion Host 생성
az network bastion create -n BastionHost01 --public-ip-address $BastionPIP -g $RgName --vnet-name $Vnet01Name --location $Location


#ELB 생성
az network lb create -g $RgName --name $ELB01Name --sku Standard --public-ip-address $ELB01PIP --backend-pool-name $ELB01BkPool01

#ELB 상태 프로브 만들기
az network lb probe create -g $RgName --lb-name $ELB01Name --name $ELB01HTTPProbe --protocol tcp --port 80

#ELB 부하 분산 규칙 생성
az network lb rule create -g $RgName --lb-name $ELB01Name --name HTTPRule --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name LoadBalancerFrontEnd --backend-pool-name $ELB01BkPool01 --probe-name $ELB01HTTPProbe --idle-timeout 4

#ELB 인바운드 NAT 규칙 생성
az network lb inbound-nat-rule create -g $RgName --frontend-ip-name LoadBalancerFrontEnd --lb-name $ELB01Name --name $ELB01NAT01 --protocol Tcp --frontend-port 30001 --backend-port 3389
az network lb inbound-nat-rule create -g $RgName --frontend-ip-name LoadBalancerFrontEnd --lb-name $ELB01Name --name $ELB01NAT02 --protocol Tcp --frontend-port 30002 --backend-port 3389

#ILB 생성
az network lb create -g $RgName --name $ILB01Name --vnet-name $Vnet01Name --subnet $Subnet02Name --sku Standard --public-ip-address "" --private-ip-address $ILB01IP --backend-pool-name $ILB01BkPool01

#ILB 상태 프로브 만들기
az network lb probe create -g $RgName --lb-name $ILB01Name --name $ILB01DBProbe --protocol tcp --port 3306

#ILB 부하 분산 규칙 생성
az network lb rule create -g $RgName --lb-name $ILB01Name --name DBRule --protocol tcp --frontend-port 3306 --backend-port 3306 --frontend-ip-name LoadBalancerFrontEnd --backend-pool-name $ILB01BkPool01 --probe-name $ILB01DBProbe --idle-timeout 4

#ILB 인바운드 NAT 규칙 생성
az network lb inbound-nat-rule create -g $RgName --frontend-ip-name LoadBalancerFrontEnd --lb-name $ILB01Name --name $ILB01NAT01 --protocol Tcp --frontend-port 30001 --backend-port 3389
az network lb inbound-nat-rule create -g $RgName --frontend-ip-name LoadBalancerFrontEnd --lb-name $ILB01Name --name $ILB01NAT02 --protocol Tcp --frontend-port 30002 --backend-port 3389


#VM에 IIS 설치
az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name $VM01Name -g $RgName --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name $VM02Name -g $RgName --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

#VM 3, 4는 DB 관련으로 추후에 추가
#여기서는 Storage만 추가하려했지만 보류
#az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name $VM04Name -g $RgName \
#--settings '{"commandToExecute":"cmd.exe /C cmdkey add:$StAccName$Fileurl user:Azure\$StAccName /pass:$keys; powershell New-PSDrive -Name Z -PSProvider FileSystem -Root "$StAccName$Fileurl\FileShareName" -Persist}'

#az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name $VM04Name -g $RgName \
#	--settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


#ELB 백엔드 풀에 VM 추가
az network nic ip-config address-pool add -g $RgName --nic-name $VM01Nic --ip-config-name $VM01ipconfig --lb-name $ELB01Name --address-pool $ELB01BkPool01
az network nic ip-config address-pool add -g $RgName --nic-name $VM02Nic --ip-config-name $VM02ipconfig --lb-name $ELB01Name --address-pool $ELB01BkPool01
az network nic ip-config address-pool add -g $RgName --nic-name $VM03Nic --ip-config-name $VM03ipconfig --lb-name $ILB01Name --address-pool $ILB01BkPool01
az network nic ip-config address-pool add -g $RgName --nic-name $VM04Nic --ip-config-name $VM04ipconfig --lb-name $ILB01Name --address-pool $ILB01BkPool01

#ELB 인바운드 NAT 규칙 설정
az network nic ip-config inbound-nat-rule add -g $RgName --nic-name $VM01Nic --ip-config-name $VM01ipconfig --lb-name $ELB01Name --inbound-nat-rule $ELB01NAT01
az network nic ip-config inbound-nat-rule add -g $RgName --nic-name $VM02Nic --ip-config-name $VM02ipconfig --lb-name $ELB01Name --inbound-nat-rule $ELB01NAT02
az network nic ip-config inbound-nat-rule add -g $RgName --nic-name $VM03Nic --ip-config-name $VM03ipconfig --lb-name $ILB01Name --inbound-nat-rule $ILB01NAT01
az network nic ip-config inbound-nat-rule add -g $RgName --nic-name $VM04Nic --ip-config-name $VM04ipconfig --lb-name $ILB01Name --inbound-nat-rule $ILB01NAT02


#ELB Public IP 확인 (웹 서비스 확인)
az network public-ip show -g $RgName -n $ELB01PIP --query [ipAddress] -o tsv

#JumpBox VM IP 확인
az network public-ip show -g $RgName -n $JMPPIP --query [ipAddress] -o tsv

#접속 확인
# mstsc ELB Public IP:30001
# ID=azureuser
# PW=Azurexptmxm123

# 스토리지 연결(네트워크 드라이브 Windows)
# 다시 부팅할 때 드라이브가 유지되도록 암호를 저장합니다.
echo "Copy to bottom command (2 lines) and paste Windows Server PowerShell"
echo "cmd.exe /C "cmdkey /add:\"$StAccName$Fileurl\" /user:\"Azure\\$StAccName\" /pass:\"$keys\"""
# 드라이브 탑재
echo "New-PSDrive -Name Z -PSProvider FileSystem -Root "\\\\$StAccName$Fileurl\\$FileShareName" -Persist"
