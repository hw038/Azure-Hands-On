#자원명
$RgName="Hands-On-5-RG"
$Location="eastus"
$Vnet01Name="Hands-On-5-VNet01"
$Vnet02Name="Hands-On-5-VNet02"
$Subnet01Name="Hands-On-5-Subnet01"
$Subnet02Name="Hands-On-5-Subnet02"
$GatewaySubnet="GatewaySubnet"
$VGWPIP="VGatewayPIP"
$VGWName="Hands-On-5-VGW"
$NSG01Name="Hands-On-5-NSG01"
$NSG02Name="Hands-On-5-NSG02"
$VMAvSet01Name="AvSet01"
$ELB01Name="Hands-On-5-ELB01"
$ELB01PIP="ELB01PIP"
$ELB01BkPool01="ELB01BackPool01"
$ELB01HTTPProbe="Health80Probe"
$ELB01NAT01="VM01RDP"
$ELB01NAT02="VM02RDP"
$VM01Name="Hands-On-5-VM01"
$VM01Nic="Hands-On-5-VM01VMNic"
$VM01ipconfig="ipconfigHands-On-5-VM01"
$VM02Name="Hands-On-5-VM02"
$VM02Nic="Hands-On-5-VM02VMNic"
$VM02ipconfig="ipconfigHands-On-5-VM02"
$VM03Name="Hands-On-5-VM03"
$VM03Nic="Hands-On-5-VM03VMNic"
$VM03ipconfig="ipconfigHands-On-5-VM03"
$VM01IP="10.1.0.4"
$VM02IP="10.1.0.5"
$VM03IP="192.168.1.20"
$RouteTableName="Hands-On-5-RT"


# On-Pre 자원명
$OnRgName="Hands-On-5-OnRG"
$OnLocation="westus"
$OnNSG01Name="Hands-On-5-OnNSG01"
$OnVnet01Name="Hands-On-5-OnVNet"
$OnSubnet01Name="Hands-On-5-OnSubnet"
$OnGatewaySubnet="GatewaySubnet"
$OnVGWPIP="OnVGatewayPIP"
$OnVGWName="Hands-On-5-OnVGW"
$OnNSG01Name="Hands-On-5-OnNSG"
$OnVM01Name="Hands-On-5-OnVM"
$OnVM01Nic="Hands-On-5-OnVMVMNic"
$OnVM01ipconfig="ipconfigHands-On-5-OnVM"
$OnVM01IP="20.0.0.4"
$OnVMPIP="Hands-On-5-OnVMPIP"

$ID="azureuser"
$PW=ConvertTo-SecureString "Azurexptmxm123" -AsPlainText -Force

#계정 정보 세팅
$Credential = New-Object System.Management.Automation.PSCredential ($ID, $PW);

New-AzResourceGroup -Name $RgName -Location $Location

#On RG
New-AzResourceGroup -Name $OnRgName -Location $OnLocation


#Public IP 생성(ELB)
$StrELB01PIP = New-AzPublicIpAddress -Name $ELB01PIP -ResourceGroupName $RgName -Location $Location -AllocationMethod Static -Sku Standard
$StrVGWPIP = New-AzPublicIpAddress -Name $VGWPIP -ResourceGroupName $RgName -Location $Location -AllocationMethod Dynamic -Sku Basic
$StrOnVGWPIP = New-AzPublicIpAddress -Name $OnVGWPIP -ResourceGroupName $OnRgName -Location $OnLocation -AllocationMethod Dynamic -Sku Basic
$StrOnMVPIP =  New-AzPublicIpAddress -Name $OnVMPIP -ResourceGroupName $OnRgName -Location $OnLocation -AllocationMethod Static -Sku Standard


#NSG 규칙 설정 및 생성
$rdpRule= New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$sshRule = New-AzNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 150 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22
$httpRule = New-AzNetworkSecurityRuleConfig -Name http-rule -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80
$StrNSG01 = New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $Location -Name $NSG01Name -SecurityRules $rdpRule,$sshRule,$httpRule
$StrNSG02 = New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $Location -Name $NSG02Name -SecurityRules $rdpRule,$sshRule,$httpRule

#On NSG
$OnStrNSG01 = New-AzNetworkSecurityGroup -ResourceGroupName $OnRgName -Location $OnLocation -Name $OnNSG01Name -SecurityRules $rdpRule,$sshRule,$httpRule

#Route Table 세팅
$Route = New-AzRouteConfig -Name "RT01" -AddressPrefix 192.168.0.0/16 -NextHopType "VirtualAppliance" -NextHopIpAddress $VM03IP
$routeTable = New-AzRouteTable -Name $RouteTableName -ResourceGroupName $RgName -Location $Location -Route $Route

$StrSubnet01 = New-AzVirtualNetworkSubnetConfig -Name $Subnet01Name -AddressPrefix "10.1.0.0/16" -NetworkSecurityGroup $StrNSG01 -RouteTable $routeTable
$StrSubnet02 = New-AzVirtualNetworkSubnetConfig -Name $Subnet02Name -AddressPrefix "192.168.1.0/26" -NetworkSecurityGroup $StrNSG02

#On Subnet
$OnStrSubnet01 = New-AzVirtualNetworkSubnetConfig -Name $OnSubnet01Name -AddressPrefix "20.0.0.0/16" -NetworkSecurityGroup $OnStrNSG01
$StrGatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name $GatewaySubnet -AddressPrefix "10.100.100.0/24"
$OnStrGatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name $OnGatewaySubnet -AddressPrefix "20.100.100.0/24"


$StrVnet01 = New-AzVirtualNetwork -Name $Vnet01Name -ResourceGroupName $RgName -Location $Location -AddressPrefix 10.0.0.0/8 -Subnet $StrSubnet01,$StrGatewaySubnet
$StrVnet02 = New-AzVirtualNetwork -Name $Vnet02Name -ResourceGroupName $RgName -Location $Location -AddressPrefix 192.168.0.0/16 -Subnet $StrSubnet02

#On Vnet
$OnStrVnet01 = New-AzVirtualNetwork -Name $OnVnet01Name -ResourceGroupName $OnRgName -Location $OnLocation -AddressPrefix 20.0.0.0/8 -Subnet $OnStrSubnet01,$OnStrGatewaySubnet


#VGW Subnet, VGW 생성
$StrGatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name $GatewaySubnet -VirtualNetwork $StrVnet01
$strgwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $StrGatewaySubnet.Id -PublicIpAddressId $StrVGWPIP.Id
$strVGW = New-AzVirtualNetworkGateway -Name $VGWName -ResourceGroupName $RgName -Location $Location -IpConfigurations $strgwipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw1 -AsJob

$OnStrGatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name $OnGatewaySubnet -VirtualNetwork $OnStrVnet01
$Onstrgwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name Ongwipconfig1 -SubnetId $OnStrGatewaySubnet.Id -PublicIpAddressId $StrOnVGWPIP.Id
$OnstrVGW = New-AzVirtualNetworkGateway -Name $OnVGWName -ResourceGroupName $OnRgName -Location $OnLocation -IpConfigurations $Onstrgwipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw1 -AsJob

#NIC 생성
$StrVM01IP = New-AzNetworkInterfaceIpConfig -Name $VM01Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM01IP -SubnetId $StrVnet01.Subnets[0].Id
$StrVM02IP = New-AzNetworkInterfaceIpConfig -Name $VM02Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM02IP -SubnetId $StrVnet01.Subnets[0].Id
$StrVM03IP = New-AzNetworkInterfaceIpConfig -Name $VM03Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM03IP -SubnetId $StrVnet02.Subnets[0].Id

#On NIC
$OnStrVM01IP = New-AzNetworkInterfaceIpConfig -Name $OnVM01Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $OnVM01IP -PublicIpAddress $StrOnMVPIP -SubnetId $OnStrVnet01.Subnets[0].Id


#VM AvSet 생성
$availSet01 = New-AzAvailabilitySet -ResourceGroupName $RgName -Name $VMAvSet01Name -Location $Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5 -Sku Aligned

#ELB 세팅
$elbfrontend = New-AzLoadBalancerFrontendIpConfig -Name "LoadBalancerFrontEnd" -PublicIpAddress $StrELB01PIP
$elbbackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $ELB01BkPool01
$elbprobe = New-AzLoadBalancerProbeConfig -Name $ELB01HTTPProbe -Protocol "http" -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -RequestPath /
$inboundNatRule1 = New-AzLoadBalancerInboundNatRuleConfig -Name $ELB01NAT01 -FrontendIPConfiguration $elbfrontend -Protocol "Tcp" -FrontendPort 30001 -BackendPort 3389 -IdleTimeoutInMinutes 4
$inboundNatRule2 = New-AzLoadBalancerInboundNatRuleConfig -Name $ELB01NAT02 -FrontendIPConfiguration $elbfrontend -Protocol "Tcp" -FrontendPort 30002 -BackendPort 3389 -IdleTimeoutInMinutes 4
$elblbrule = New-AzLoadBalancerRuleConfig -Name "HTTP-Rule" -FrontendIPConfiguration $elbfrontend -BackendAddressPool $elbbackendAddressPool -Probe $probe -Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -LoadDistribution SourceIP

$elb = New-AzLoadBalancer -Name $ELB01Name -ResourceGroupName $RgName -Location $Location -FrontendIpConfiguration $elbfrontend -BackendAddressPool $elbbackendAddressPool -Probe $elbprobe -InboundNatRule $inboundNatRule1,$inboundNatRule2 -LoadBalancingRule $elblbrule -Sku Standard


#VM 만들기
$StrVM01NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM01Nic -LoadBalancerBackendAddressPool $elbbackendAddressPool -LoadBalancerInboundNatRule $inboundNatRule1 -Subnet $StrVnet01.Subnets[0] -force
$StrVM02NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM02Nic -LoadBalancerBackendAddressPool $elbbackendAddressPool -LoadBalancerInboundNatRule $inboundNatRule2 -Subnet $StrVnet01.Subnets[0] -force
$StrVM03NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM03Nic -Subnet $StrVnet02.Subnets[0] -force

#On VM
$OnStrVM01NIC = New-AzNetworkInterface -ResourceGroupName $OnRgName -Location $OnLocation -Name $OnVM01Nic -Subnet $OnStrVnet01.Subnets[0] -force

#On-Prem VM PIP를 VM NIC에 연결
$vnet = Get-AzVirtualNetwork -Name $OnVnet01Name -ResourceGroupName $OnRgName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $OnSubnet01Name -VirtualNetwork $vnet
$nic = Get-AzNetworkInterface -Name $OnVM01Nic -ResourceGroupName $OnRgName
$pip = Get-AzPublicIpAddress -Name $OnVMPIP -ResourceGroupName $OnRgName
$nic | Set-AzNetworkInterfaceIpConfig -Name ipconfig1 -PublicIPAddress $pip -Subnet $subnet
$nic | Set-AzNetworkInterface


#PowerShell로 NIC Private IP 생성 시 Static으로 설정되어야하나 Dynamic으로 설정되는 오류 있으므로 수동으로 다시 한번 더 설정
$StrVM03NIC = Get-AzNetworkInterface -ResourceGroupName $RgName -Name $VM03Nic
$StrVM03NIC.IpConfigurations[0].PrivateIpAddress = "192.168.1.20"
$StrVM03NIC.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
Set-AzNetworkInterface -NetworkInterface $StrVM03NIC


$StrVM01 = New-AzVMConfig -VMName $VM01Name -VMSize "Standard_D1_v2" -AvailabilitySetId $availSet01.Id
$StrVM01 = Set-AzVMOperatingSystem -VM $StrVM01 -Windows -ComputerName $VM01Name -Credential $Credential
$StrVM01 = Add-AzVMNetworkInterface -VM $StrVM01 -Id $StrVM01NIC.Id
$StrVM01 = Set-AzVMSourceImage -VM $StrVM01 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrVM01 -Verbose -DisableBginfoExtension -AsJob

$StrVM02 = New-AzVMConfig -VMName $VM02Name -VMSize "Standard_D1_v2" -AvailabilitySetId $availSet01.Id
$StrVM02 = Set-AzVMOperatingSystem -VM $StrVM02 -Windows -ComputerName $VM02Name -Credential $Credential
$StrVM02 = Add-AzVMNetworkInterface -VM $StrVM02 -Id $StrVM02NIC.Id
$StrVM02 = Set-AzVMSourceImage -VM $StrVM02 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrVM02 -Verbose -DisableBginfoExtension -AsJob


$StrVM03 = New-AzVMConfig -VMName $VM03Name -VMSize "Standard_D1_v2"
$StrVM03 = Set-AzVMOperatingSystem -VM $StrVM03 -Windows -ComputerName $VM03Name -Credential $Credential
$StrVM03 = Add-AzVMNetworkInterface -VM $StrVM03 -Id $StrVM03NIC.Id
$StrVM03 = Set-AzVMSourceImage -VM $StrVM03 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrVM03 -Verbose -DisableBginfoExtension -AsJob

$OnStrVM01 = New-AzVMConfig -VMName $OnVM01Name -VMSize "Standard_D1_v2"
$OnStrVM01 = Set-AzVMOperatingSystem -VM $OnStrVM01 -Windows -ComputerName $OnVM01Name -Credential $Credential
$OnStrVM01 = Add-AzVMNetworkInterface -VM $OnStrVM01 -Id $OnStrVM01NIC.Id
$OnStrVM01 = Set-AzVMSourceImage -VM $OnStrVM01 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $OnRgName -Location $OnLocation -VM $OnStrVM01 -Verbose -DisableBginfoExtension -AsJob


#IIS 설치(VM01, 02)
Set-AzVMExtension -ResourceGroupName $RgName -Publisher Microsoft.Compute -ExtensionType CustomScriptExtension -ExtensionName IIS -VMName $VM01Name -Location $Location -TypeHandlerVersion 1.8 -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' -AsJob
Set-AzVMExtension -ResourceGroupName $RgName -Publisher Microsoft.Compute -ExtensionType CustomScriptExtension -ExtensionName IIS -VMName $VM02Name -Location $Location -TypeHandlerVersion 1.8 -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' -AsJob

az network vnet peering create --name "Hands-On-4-Peering" --remote-vnet $Vnet02Name -g $RgName --vnet-name $Vnet01Name --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create --name "Hands-On-4-Peering" --remote-vnet $Vnet01Name -g $RgName --vnet-name $Vnet02Name --allow-vnet-access --allow-forwarded-traffic --use-remote-gateways

#Peering Setting
Add-AzVirtualNetworkPeering -Name 'Hands-On-4-Peering' -VirtualNetwork $StrVnet01 -RemoteVirtualNetworkId $StrVnet02.Id -AllowForwardedTraffic -AllowGatewayTransit -AsJob
Add-AzVirtualNetworkPeering -Name 'Hands-On-4-Peering' -VirtualNetwork $StrVnet02 -RemoteVirtualNetworkId $StrVnet01.Id -AllowForwardedTraffic -UseRemoteGateways -AsJob


#VGW Public IP 확인
$ipVGWIP = Get-AzPublicIpAddress -Name $VGWPIP -ResourceGroupName $RgName | Select IpAddress | awk 'NR==4'
$OnipVGWIP = Get-AzPublicIpAddress -Name $OnVGWPIP -ResourceGroupName $OnRgName | Select IpAddress | awk 'NR==4'


#VGW Public IP 정상 상태인지 확인 후 아래 진행
echo $ipVGWIP
echo $OnipVGWIP

#Local Network Gateway 생성
#$local = New-AzLocalNetworkGateway -Name 'toOnVGW' -ResourceGroupName $RgName -Location $Location -GatewayIpAddress $OnipVGWIP -AddressPrefix "20.0.0.0/8"
#$Onlocal = New-AzLocalNetworkGateway -Name 'toVGW' -ResourceGroupName $OnRgName -Location $OnLocation -GatewayIpAddress $ipVGWIP -AddressPrefix @('10.0.0.0/8','192.168.0.0/16')


#VGW Connection 추가
#New-AzVirtualNetworkGatewayConnection -Name 'Azure-to-OnPrem' -ResourceGroupName $RgName -Location $Location -VirtualNetworkGateway1 $strVGW -LocalNetworkGateway2 $local -ConnectionType IPsec -RoutingWeight 10 -SharedKey 'xptmxm123'
#New-AzVirtualNetworkGatewayConnection -Name 'OnPrem-to-Azure' -ResourceGroupName $OnRgName -Location $OnLocation -VirtualNetworkGateway1 $StrOnVGWPIP -LocalNetworkGateway2 $Onlocal -ConnectionType IPsec -RoutingWeight 10 -SharedKey 'xptmxm123'
