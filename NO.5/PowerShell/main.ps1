#!/bin/sh

# 자원명
RgName="Hands-On-5-RG"
Location="eastus"
Vnet01Name="Hands-On-5-VNet01"
Vnet02Name="Hands-On-5-VNet02"
Subnet01Name="Hands-On-5-Subnet01"
Subnet02Name="Hands-On-5-Subnet02"
GatewaySubnet="GatewaySubnet"
VGWPIP="VGatewayPIP"
VGWName="Hands-On-5-VGateway"
NSG01Name="Hands-On-5-NSG01"
NSG02Name="Hands-On-5-NSG02"
VMAvSet01Name="AvSet01"
ELB01Name="Hands-On-5-ELB01"
ELB01PIP="ELB01PIP"
ELB01BkPool01="ELB01BackPool01"
ELB01HTTPProbe="Health80Probe"
ELB01NAT01="VM01RDP"
ELB01NAT02="VM02RDP"
VM01Name="Hands-On-5-VM01"
VM01Nic="Hands-On-5-VM01VMNic"
VM01ipconfig="ipconfigHands-On-5-VM01"
VM02Name="Hands-On-5-VM02"
VM02Nic="Hands-On-5-VM02VMNic"
VM02ipconfig="ipconfigHands-On-5-VM02"
VM03Name="Hands-On-5-VM03"
VM03Nic="Hands-On-5-VM03VMNic"
VM03ipconfig="ipconfigHands-On-5-VM03"
VM01IP="10.1.0.4"
VM02IP="10.1.0.5"
VM03IP="192.168.1.20"
RouteTableName="Hands-On-5-RT"


# On-Pre 자원명
OnRgName="Hands-On-5-OnRG"
OnLocation="westus"
OnNSG01Name="Hands-On-5-OnNSG01"
OnVnet01Name="Hands-On-5-OnVNet"
OnSubnet01Name="Hands-On-5-OnSubnet"
OnGatewaySubnet="GatewaySubnet"
OnVGWPIP="OnVGatewayPIP"
OnVGWName="Hands-On-5-OnVGateway"
OnNSG01Name="Hands-On-5-OnNSG"
OnVM01Name="Hands-On-5-OnVM"
OnVM01Nic="Hands-On-5-OnVMVMNic"
OnVM01ipconfig="ipconfigHands-On-5-OnVM"
OnVM01IP="20.0.0.4"
OnVMPIP="Hands-On-5-OnVMPIP"

ID="azureuser"
PW="Azurexptmxm123"

#---------------------------------------------------------------------------------

az group create --name $RgName --location $Location

#On RG
az group create --name $OnRgName --location $OnLocation

az network vnet create --name $Vnet01Name -g $RgName --location $Location --address-prefix 10.0.0.0/8
az network vnet create --name $Vnet02Name -g $RgName --location $Location --address-prefix 192.168.0.0/16

#On Vnet
az network vnet create --name $OnVnet01Name -g $OnRgName --location $OnLocation --address-prefix 20.0.0.0/8


#Route Table 세팅
az network route-table create --name $RouteTableName -g $RgName --location $Location
az network route-table route create --address-prefix 192.168.0.0/16 --name "RT01" --next-hop-type VirtualAppliance -g $RgName --route-table-name $RouteTableName --next-hop-ip-address $VM03IP


az network vnet subnet create --address-prefixes 10.1.0.0/16 --name $Subnet01Name -g $RgName --vnet-name $Vnet01Name --route-table $RouteTableName
az network vnet subnet create --address-prefixes 192.168.1.0/26 --name $Subnet02Name -g $RgName --vnet-name $Vnet02Name


#VGW IP의 경우 SKU가 Basic이여야한다. CLI로 생성 중 Standard로 생성하게 되면 VPN 연결을 할 수 없으니 주의
az network public-ip create -g $RgName --name $VGWPIP --sku Basic
az network public-ip create -g $OnRgName --name $OnVGWPIP --sku Basic

#Azure vgw 생성
az network vnet subnet create --address-prefixes 10.100.100.0/24 --name $GatewaySubnet -g $RgName --vnet-name $Vnet01Name
az network vnet-gateway create -n $VGWName -l $Location --public-ip-address $VGWPIP -g $RgName --vnet $Vnet01Name --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --no-wait

#On vgw 생성
az network vnet subnet create --address-prefixes 20.0.0.0/24 --name $OnSubnet01Name -g $OnRgName --vnet-name $OnVnet01Name
az network vnet subnet create --address-prefixes 20.100.200.0/24 --name $OnGatewaySubnet -g $OnRgName --vnet-name $OnVnet01Name
az network vnet-gateway create -n $OnVGWName -l $OnLocation --public-ip-address $OnVGWPIP -g $OnRgName --vnet $OnVnet01Name --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --no-wait

az network nsg create -g $RgName --n $NSG01Name --location $Location
az network nsg create -g $RgName --n $NSG02Name --location $Location
az network nsg create -g $OnRgName --n $OnNSG01Name --location $OnLocation


#NSG 80, 22, 3389 Allow Rule 생성
az network nsg rule create -g $RgName --nsg-name $NSG01Name --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range 80
az network nsg rule create -g $RgName --nsg-name $NSG01Name --name Allow-SSH-All --access Allow --protocol Tcp --direction Inbound --priority 150 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22
az network nsg rule create -g $RgName --nsg-name $NSG01Name --name Allow-RDP-All --access Allow --protocol Tcp --direction Inbound --priority 250 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3389

#NSG 규칙 Vnet, Subnet에 연결
az network vnet subnet update --vnet-name $Vnet01Name --name $Subnet01Name -g $RgName --network-security-group $NSG01Name

az network nsg rule create -g $RgName --nsg-name $NSG02Name --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range 80
az network nsg rule create -g $RgName --nsg-name $NSG02Name --name Allow-SSH-All --access Allow --protocol Tcp --direction Inbound --priority 150 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22
az network nsg rule create -g $RgName --nsg-name $NSG02Name --name Allow-RDP-All --access Allow --protocol Tcp --direction Inbound --priority 250 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3389

az network vnet subnet update --vnet-name $Vnet02Name --name $Subnet02Name -g $RgName --network-security-group $NSG02Name


#On NSG
az network nsg rule create -g $OnRgName --nsg-name $OnNSG01Name --name Allow-HTTP-All --access Allow --protocol Tcp --direction Inbound --priority 100 --source-address-prefix Internet --source-port-range "*" --destination-address-prefix "*" --destination-port-range 80
az network nsg rule create -g $OnRgName --nsg-name $OnNSG01Name --name Allow-SSH-All --access Allow --protocol Tcp --direction Inbound --priority 150 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22
az network nsg rule create -g $OnRgName --nsg-name $OnNSG01Name --name Allow-RDP-All --access Allow --protocol Tcp --direction Inbound --priority 250 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 3389

az network vnet subnet update --vnet-name $OnVnet01Name --name $OnSubnet01Name -g $OnRgName --network-security-group $OnNSG01Name


#VM AvSet 생성
az vm availability-set create -n $VMAvSet01Name -g $RgName --platform-fault-domain-count 2 --platform-update-domain-count 5

#VM 생성
az vm create -g $RgName --location $Location --name $VM01Name --vnet-name $Vnet01Name --subnet $Subnet01Name --nsg $NSG01Name --public-ip-address "" --private-ip-address $VM01IP --public-ip-sku Standard --public-ip-address-allocation static --availability-set $VMAvSet01Name --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait
az vm create -g $RgName --location $Location --name $VM02Name --vnet-name $Vnet01Name --subnet $Subnet01Name --nsg $NSG01Name --public-ip-address "" --private-ip-address $VM02IP --public-ip-sku Standard --public-ip-address-allocation static --availability-set $VMAvSet01Name --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait
az vm create -g $RgName --location $Location --name $VM03Name --vnet-name $Vnet02Name --subnet $Subnet02Name --nsg $NSG02Name --public-ip-address "" --private-ip-address $VM03IP --public-ip-sku Standard --public-ip-address-allocation static --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait


az vm create -g $OnRgName --location $OnLocation --name $OnVM01Name --vnet-name $OnVnet01Name --subnet $OnSubnet01Name --nsg $OnNSG01Name --public-ip-address $OnVMPIP --private-ip-address $OnVM01IP --public-ip-sku Standard --public-ip-address-allocation static --image win2016datacenter --admin-username azureuser --admin-password $PW --no-wait


#ELB PIP 생성
az network public-ip create -g $RgName --name $ELB01PIP --sku Standard --zone 1


#ELB 생성
az network lb create -g $RgName --name $ELB01Name --sku Standard --public-ip-address $ELB01PIP --backend-pool-name $ELB01BkPool01

#ELB 상태 프로브 만들기
az network lb probe create -g $RgName --lb-name $ELB01Name --name $ELB01HTTPProbe --protocol tcp --port 80

#ELB 부하 분산 규칙 생성
az network lb rule create -g $RgName --lb-name $ELB01Name --name HTTPRule --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name LoadBalancerFrontEnd --backend-pool-name $ELB01BkPool01 --probe-name $ELB01HTTPProbe --idle-timeout 4

#ELB 인바운드 NAT 규칙 생성
az network lb inbound-nat-rule create -g $RgName --frontend-ip-name LoadBalancerFrontEnd --lb-name $ELB01Name --name $ELB01NAT01 --protocol Tcp --frontend-port 30001 --backend-port 3389
az network lb inbound-nat-rule create -g $RgName --frontend-ip-name LoadBalancerFrontEnd --lb-name $ELB01Name --name $ELB01NAT02 --protocol Tcp --frontend-port 30002 --backend-port 3389


#ELB 백엔드 풀에 VM 추가(적용)
az network nic ip-config address-pool add -g $RgName --nic-name $VM01Nic --ip-config-name $VM01ipconfig --lb-name $ELB01Name --address-pool $ELB01BkPool01
az network nic ip-config address-pool add -g $RgName --nic-name $VM02Nic --ip-config-name $VM02ipconfig --lb-name $ELB01Name --address-pool $ELB01BkPool01

#ELB 인바운드 NAT 규칙 적용
az network nic ip-config inbound-nat-rule add -g $RgName --nic-name $VM01Nic --ip-config-name $VM01ipconfig --lb-name $ELB01Name --inbound-nat-rule $ELB01NAT01
az network nic ip-config inbound-nat-rule add -g $RgName --nic-name $VM02Nic --ip-config-name $VM02ipconfig --lb-name $ELB01Name --inbound-nat-rule $ELB01NAT02


#Peering 세팅
az network vnet peering create --name "Hands-On-4-Peering" --remote-vnet $Vnet02Name -g $RgName --vnet-name $Vnet01Name --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create --name "Hands-On-4-Peering" --remote-vnet $Vnet01Name -g $RgName --vnet-name $Vnet02Name --allow-vnet-access --allow-forwarded-traffic --use-remote-gateways



#VGW PIP 확인 및 OnVGW에서 연결 작업
Vgwip=`az network public-ip show -g $RgName -n $VGWPIP --query [ipAddress] -o tsv`
OnVgwip=`az network public-ip show -g $OnRgName -n $OnVGWPIP --query [ipAddress] -o tsv`


# local gateway 생성
# to OnVGW & to VGW
az network local-gateway create --gateway-ip-address $OnVgwip --name "toOnVGW" -g $RgName --local-address-prefixes 20.0.0.0/8
az network local-gateway create --gateway-ip-address $Vgwip --name "toVGW" -g $OnRgName --local-address-prefixes 10.0.0.0/8 192.168.0.0/16


VGW 생성 완료 확인 후 진행
#---------------------------------------------------------------------------------

#VGW에 연결 추가
#az network vpn-connection create --name "Azure-to-OnPrem" --resource-group $RgName --vnet-gateway1 $VGWName -l $Location --shared-key xptmxm123 --local-gateway2 toOnVGW
#az network vpn-connection create --name "OnPrem-to-Azure" --resource-group $OnRgName --vnet-gateway1 $OnVGWName -l $OnLocation --shared-key xptmxm123 --local-gateway2 toVGW


# On-Prem PIP 확인하여 3389 접속
az network public-ip show -g $RgName -n $OnVMPIP --query [ipAddress] -o tsv

#VM01=10.1.0.4
#VM03=192.168.1.20

#VPN 연결된 타 지역 VM에 연결 테스트
