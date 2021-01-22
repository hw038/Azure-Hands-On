#자원 변수 선언
$RgName="Hands-On-1-RG"
$Location="eastus"
$Vnet01Name="Hands-On-1-VNet01"
$Subnet01Name="Hands-On-1-Subnet01"
$NSG01Name="Hands-On-1-NSG01"
$ELB01Name="Hands-On-1-ELB01"
$ELB01PIP="ELB01PIP"
$ELB01BkPool01="ELB01BackPool01"
$ELB01HTTPProbe="Health80Probe"
$ELB01NAT01="VM01RDP"
$ELB01NAT02="VM02RDP"
$VM01Name="Hands-On-1-VM01"
$VM01Nic="Hands-On-1-VM01VMNic"
$VM01ipconfig="ipconfigHands-On-1-VM01"
$VM02Name="Hands-On-1-VM02"
$VM02Nic="Hands-On-1-VM02VMNic"
$VM02ipconfig="ipconfigHands-On-1-VM02"
$VMAvSet01Name="AvSet01"
$VM01IP="10.1.0.4"
$VM02IP="10.1.0.5"
$ID="azureuser"
$PW=ConvertTo-SecureString "Azurexptmxm123" -AsPlainText -Force


New-AzResourceGroup `
	-Name $RgName `
	-Location $Location

#NSG 규칙 설정 및 생성
$rdpRule= New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$sshRule = New-AzNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 150 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22
$httpRule = New-AzNetworkSecurityRuleConfig -Name http-rule -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80
$StrNSG01 = New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $Location -Name $NSG01Name -SecurityRules $rdpRule,$sshRule,$httpRule


$StrSubnet01 = New-AzVirtualNetworkSubnetConfig -Name $Subnet01Name -AddressPrefix "10.1.0.0/16" -NetworkSecurityGroup $StrNSG01
$StrVnet01 = New-AzVirtualNetwork -Name $Vnet01Name -ResourceGroupName $RgName -Location $Location -AddressPrefix 10.0.0.0/8 -Subnet $StrSubnet01

$StrVM01IP = New-AzNetworkInterfaceIpConfig -Name $VM01Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM01IP -SubnetId $StrVnet01.Subnets[0].Id
$StrVM02IP = New-AzNetworkInterfaceIpConfig -Name $VM02Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM02IP -SubnetId $StrVnet01.Subnets[0].Id

#VM AvSet 생성
$availSet = New-AzAvailabilitySet `
   -ResourceGroupName $RgName `
   -Name $VMAvSet01Name `
   -Location $Location `
   -PlatformFaultDomainCount 2 `
   -PlatformUpdateDomainCount 5 `
   -Sku Aligned

#계정 정보 세팅
$Credential = New-Object System.Management.Automation.PSCredential ($ID, $PW);

#Public IP 생성(ELB)
$StrELB01PIP = New-AzPublicIpAddress -Name $ELB01PIP -ResourceGroupName $RgName -Location $Location -AllocationMethod Static -Sku Standard
$frontend = New-AzLoadBalancerFrontendIpConfig -Name "LoadBalancerFrontEnd" -PublicIpAddress $StrELB01PIP
$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $ELB01BkPool01
$probe = New-AzLoadBalancerProbeConfig -Name $ELB01HTTPProbe -Protocol "http" -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -RequestPath /
$inboundNatRule1 = New-AzLoadBalancerInboundNatRuleConfig -Name $ELB01NAT01 -FrontendIPConfiguration $frontend -Protocol "Tcp" -FrontendPort 30001 -BackendPort 3389 -IdleTimeoutInMinutes 4
$inboundNatRule2 = New-AzLoadBalancerInboundNatRuleConfig -Name $ELB01NAT02 -FrontendIPConfiguration $frontend -Protocol "Tcp" -FrontendPort 30002 -BackendPort 3389 -IdleTimeoutInMinutes 4
$lbrule = New-AzLoadBalancerRuleConfig -Name "HTTP-Rule" -FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe -Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -LoadDistribution SourceIP

$lb = New-AzLoadBalancer -Name $ELB01Name -ResourceGroupName $RgName -Location $Location -FrontendIpConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe -InboundNatRule $inboundNatRule1,$inboundNatRule2 -LoadBalancingRule $lbrule -Sku Standard

#VM 만들기
$StrVM01NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM01Nic -LoadBalancerBackendAddressPool $backendAddressPool -LoadBalancerInboundNatRule $inboundNatRule1 -Subnet $StrVnet01.Subnets[0] -force
$StrVM02NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM02Nic -LoadBalancerBackendAddressPool $backendAddressPool -LoadBalancerInboundNatRule $inboundNatRule2 -Subnet $StrVnet01.Subnets[0] -force

$StrVM01 = New-AzVMConfig -VMName $VM01Name -VMSize "Standard_D1_v2" -AvailabilitySetId $availSet.Id
$StrVM01 = Set-AzVMOperatingSystem -VM $StrVM01 -Windows -ComputerName $VM01Name -Credential $Credential
$StrVM01 = Add-AzVMNetworkInterface -VM $StrVM01 -Id $StrVM01NIC.Id
$StrVM01 = Set-AzVMSourceImage -VM $StrVM01 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrVM01 -Verbose

$StrVM02 = New-AzVMConfig -VMName $VM02Name -VMSize "Standard_D1_v2" -AvailabilitySetId $availSet.Id
$StrVM02 = Set-AzVMOperatingSystem -VM $StrVM02 -Windows -ComputerName $VM02Name -Credential $Credential
$StrVM02 = Add-AzVMNetworkInterface -VM $StrVM02 -Id $StrVM02NIC.Id
$StrVM02 = Set-AzVMSourceImage -VM $StrVM02 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrVM02 -Verbose

#IIS 설치
Set-AzVMExtension -ResourceGroupName $RgName `
	-Publisher Microsoft.Compute `
	-ExtensionType CustomScriptExtension `
	-ExtensionName IIS `
	-VMName $VM01Name `
	-Location $Location `
	-TypeHandlerVersion 1.8 `
	-SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

Set-AzVMExtension -ResourceGroupName $RgName `
	-Publisher Microsoft.Compute `
	-ExtensionType CustomScriptExtension `
	-ExtensionName IIS `
	-VMName $VM02Name `
	-Location $Location `
	-TypeHandlerVersion 1.8 `
	-SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


#ELB-Public-IP 확인
Get-AzPublicIpAddress -Name $ELB01PIP -ResourceGroupName $RgName | grep IpAddress

# 부하 분산 확인
# http://ELB-Public-IP
# RDP 접속 확인
# mstsc ELB-Public-IP:30001
# ID=azureuser
# PW=Azurexptmxm123
