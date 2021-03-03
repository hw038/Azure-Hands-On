# 자원명
$RgName="Hands-On-3-PS"
$Location="eastus"
$StAccName="handson3storage"
$FileShareName="handson3fs"
$Fileurl=".file.core.windows.net"
$Vnet01Name="Hands-On-3-VNet01"
$Vnet02Name="Hands-On-3-VNet02"
$Subnet01Name="Hands-On-3-Subnet01"
$Subnet02Name="Hands-On-3-Subnet02"
$BastionSubnet="AzureBastionSubnet"
$BastionPIP="Hands-On-3-BastionPIP"
$NSG01Name="Hands-On-3-NSG01"
$NSG02Name="Hands-On-3-NSG02"
$NSGJMP="Hands-On-3-JMP"
$VMAvSet01Name="AvSet01"
$VMAvSet02Name="AvSet02"
$ELB01Name="Hands-On-3-ELB01"
$ELB01PIP="ELB01PIP"
$ELB01BkPool01="ELB01BackPool01"
$ELB01HTTPProbe="Health80Probe"
$ELB01NAT01="VM01RDP"
$ELB01NAT02="VM02RDP"
$VMJump01="Hands-On-3-JBox"
$VM01Name="Hands-On-3-VM01"
$VM01Nic="Hands-On-3-VM01VMNic"
$VM01ipconfig="ipconfigHands-On-3-VM01"
$VM02Name="Hands-On-3-VM02"
$VM02Nic="Hands-On-3-VM02VMNic"
$VM02ipconfig="ipconfigHands-On-3-VM02"
$VM01IP="10.1.0.4"
$VM02IP="10.1.0.5"
$JMPPIP="JumpBoxPIP"
$JMPSubnet="Hands-On-3-JBoxSubnet"
$VMJumpNic="Hands-On-3-JBoxNic"
$ILB01Name="Hands-On-3-ILB01"
$ILB01PIP="ILB01PIP"
$ILB01BkPool01="ILB01BackPool01"
$ILB01DBProbe="Health3306Probe"
$ILB01NAT01="VM03RDP"
$ILB01NAT02="VM04RDP"
$VM03Name="Hands-On-3-VM03"
$VM03Nic="Hands-On-3-VM03VMNic"
$VM03ipconfig="ipconfigHands-On-3-VM03"
$VM04Name="Hands-On-3-VM04"
$VM04Nic="Hands-On-3-VM04VMNic"
$VM04ipconfig="ipconfigHands-On-3-VM04"
$VM03IP="10.2.0.4"
$VM04IP="10.2.0.5"
$ILB01IP="10.2.0.10"
$ID="azureuser"
$PW=ConvertTo-SecureString "Azurexptmxm123" -AsPlainText -Force


New-AzResourceGroup -Name $RgName -Location $Location

#NSG 규칙 설정 및 생성
$rdpRule= New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$sshRule = New-AzNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 150 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22
$httpRule = New-AzNetworkSecurityRuleConfig -Name http-rule -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80
$DBRule = New-AzNetworkSecurityRuleConfig -Name db-rule -Description "Allow DB" -Access Allow -Protocol Tcp -Direction Inbound -Priority 250 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3306
$StrNSG01 = New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $Location -Name $NSG01Name -SecurityRules $rdpRule,$sshRule,$httpRule
$StrNSG02 = New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $Location -Name $NSG02Name -SecurityRules $rdpRule,$sshRule,$httpRule,$DBRule
$StrNSG03 = New-AzNetworkSecurityGroup -ResourceGroupName $RgName -Location $Location -Name $NSGJMP -SecurityRules $rdpRule,$sshRule,$httpRule,$DBRule


$StrSubnet01 = New-AzVirtualNetworkSubnetConfig -Name $Subnet01Name -AddressPrefix "10.1.0.0/16" -NetworkSecurityGroup $StrNSG01
$StrSubnet02 = New-AzVirtualNetworkSubnetConfig -Name $Subnet02Name -AddressPrefix "10.2.0.0/16" -NetworkSecurityGroup $StrNSG02
$StrBastionSubnet = New-AzVirtualNetworkSubnetConfig -Name $BastionSubnet -AddressPrefix "10.100.100.0/24"
$StrJMPSubnet = New-AzVirtualNetworkSubnetConfig -Name $JMPSubnet -AddressPrefix "10.0.0.0/24" -NetworkSecurityGroup $StrNSG02


$StrVnet01 = New-AzVirtualNetwork -Name $Vnet01Name -ResourceGroupName $RgName -Location $Location -AddressPrefix 10.0.0.0/8 -Subnet $StrSubnet01,$StrSubnet02,$StrBastionSubnet,$StrJMPSubnet

$StrVM01IP = New-AzNetworkInterfaceIpConfig -Name $VM01Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM01IP -SubnetId $StrVnet01.Subnets[0].Id
$StrVM02IP = New-AzNetworkInterfaceIpConfig -Name $VM02Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM02IP -SubnetId $StrVnet01.Subnets[0].Id
$StrVM03IP = New-AzNetworkInterfaceIpConfig -Name $VM03Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM03IP -SubnetId $StrVnet01.Subnets[1].Id
$StrVM04IP = New-AzNetworkInterfaceIpConfig -Name $VM04Nic -PrivateIpAddressVersion IPv4 -PrivateIpAddress $VM04IP -SubnetId $StrVnet01.Subnets[1].Id

#VM AvSet 생성
$availSet01 = New-AzAvailabilitySet -ResourceGroupName $RgName -Name $VMAvSet01Name -Location $Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5 -Sku Aligned
$availSet02 = New-AzAvailabilitySet -ResourceGroupName $RgName -Name $VMAvSet02Name -Location $Location -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5 -Sku Aligned


#계정 정보 세팅
$Credential = New-Object System.Management.Automation.PSCredential ($ID, $PW);

#Public IP 생성(ELB)
$StrELB01PIP = New-AzPublicIpAddress -Name $ELB01PIP -ResourceGroupName $RgName -Location $Location -AllocationMethod Static -Sku Standard
$StrBastion01PIP = New-AzPublicIpAddress -Name $BastionPIP -ResourceGroupName $RgName -Location $Location -AllocationMethod Static -Sku Standard
$StrJMPPIP = New-AzPublicIpAddress -Name $JMPPIP -ResourceGroupName $RgName -Location $Location -AllocationMethod Static -Sku Standard

#ELB 세팅
$elbfrontend = New-AzLoadBalancerFrontendIpConfig -Name "LoadBalancerFrontEnd" -PublicIpAddress $StrELB01PIP
$elbbackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $ELB01BkPool01
$elbprobe = New-AzLoadBalancerProbeConfig -Name $ELB01HTTPProbe -Protocol "http" -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -RequestPath /
$inboundNatRule1 = New-AzLoadBalancerInboundNatRuleConfig -Name $ELB01NAT01 -FrontendIPConfiguration $elbfrontend -Protocol "Tcp" -FrontendPort 30001 -BackendPort 3389 -IdleTimeoutInMinutes 4
$inboundNatRule2 = New-AzLoadBalancerInboundNatRuleConfig -Name $ELB01NAT02 -FrontendIPConfiguration $elbfrontend -Protocol "Tcp" -FrontendPort 30002 -BackendPort 3389 -IdleTimeoutInMinutes 4
$elblbrule = New-AzLoadBalancerRuleConfig -Name "HTTP-Rule" -FrontendIPConfiguration $elbfrontend -BackendAddressPool $elbbackendAddressPool -Probe $probe -Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -LoadDistribution SourceIP

$elb = New-AzLoadBalancer -Name $ELB01Name -ResourceGroupName $RgName -Location $Location -FrontendIpConfiguration $elbfrontend -BackendAddressPool $elbbackendAddressPool -Probe $elbprobe -InboundNatRule $inboundNatRule1,$inboundNatRule2 -LoadBalancingRule $elblbrule -Sku Standard


#ILB 세팅

$lbip = @{
    Name = 'LoadBalancerFrontEnd'
    PrivateIpAddress = $ILB01IP
    SubnetId = $StrVnet01.subnets[1].Id
}

$ilbfrontend = New-AzLoadBalancerFrontendIpConfig @lbip
$ilbbackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $ILB01BkPool01
$ilbprobe = New-AzLoadBalancerProbeConfig -Name $ILB01DBProbe -Protocol "tcp" -Port 3306 -IntervalInSeconds 15 -ProbeCount 2
$inboundNatRule3 = New-AzLoadBalancerInboundNatRuleConfig -Name $ILB01NAT01 -FrontendIPConfiguration $ilbfrontend -Protocol "Tcp" -FrontendPort 30001 -BackendPort 3389 -IdleTimeoutInMinutes 4
$inboundNatRule4 = New-AzLoadBalancerInboundNatRuleConfig -Name $ILB01NAT02 -FrontendIPConfiguration $ilbfrontend -Protocol "Tcp" -FrontendPort 30002 -BackendPort 3389 -IdleTimeoutInMinutes 4
$ilblbrule = New-AzLoadBalancerRuleConfig -Name "DB-Rule" -FrontendIPConfiguration $ilbfrontend -BackendAddressPool $ilbbackendAddressPool -Probe $probe -Protocol "Tcp" -FrontendPort 3306 -BackendPort 3306 -IdleTimeoutInMinutes 15 -LoadDistribution SourceIP

$ilb = New-AzLoadBalancer -Name $ILB01Name -ResourceGroupName $RgName -Location $Location -FrontendIpConfiguration $ilbfrontend -BackendAddressPool $ilbbackendAddressPool -Probe $ilbprobe -InboundNatRule $inboundNatRule3,$inboundNatRule4 -LoadBalancingRule $ilblbrule


#VM 만들기
$StrVM01NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM01Nic -LoadBalancerBackendAddressPool $elbbackendAddressPool -LoadBalancerInboundNatRule $inboundNatRule1 -Subnet $StrVnet01.Subnets[0] -force
$StrVM02NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM02Nic -LoadBalancerBackendAddressPool $elbbackendAddressPool -LoadBalancerInboundNatRule $inboundNatRule2 -Subnet $StrVnet01.Subnets[0] -force
$StrVM03NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM03Nic -LoadBalancerBackendAddressPool $ilbbackendAddressPool -LoadBalancerInboundNatRule $inboundNatRule3 -Subnet $StrVnet01.Subnets[1] -force
$StrVM04NIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VM04Nic -LoadBalancerBackendAddressPool $ilbbackendAddressPool -LoadBalancerInboundNatRule $inboundNatRule4 -Subnet $StrVnet01.Subnets[1] -force
$StrJumpNIC = New-AzNetworkInterface -ResourceGroupName $RgName -Location $Location -Name $VMJumpNic -PublicIpAddress $StrJMPPIP -Subnet $StrVnet01.Subnets[3]

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


$StrVM03 = New-AzVMConfig -VMName $VM03Name -VMSize "Standard_D1_v2" -AvailabilitySetId $availSet02.Id
$StrVM03 = Set-AzVMOperatingSystem -VM $StrVM03 -Windows -ComputerName $VM03Name -Credential $Credential
$StrVM03 = Add-AzVMNetworkInterface -VM $StrVM03 -Id $StrVM03NIC.Id
$StrVM03 = Set-AzVMSourceImage -VM $StrVM03 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrVM03 -Verbose -DisableBginfoExtension -AsJob

$StrVM04 = New-AzVMConfig -VMName $VM04Name -VMSize "Standard_D1_v2" -AvailabilitySetId $availSet02.Id
$StrVM04 = Set-AzVMOperatingSystem -VM $StrVM04 -Windows -ComputerName $VM04Name -Credential $Credential
$StrVM04 = Add-AzVMNetworkInterface -VM $StrVM04 -Id $StrVM04NIC.Id
$StrVM04 = Set-AzVMSourceImage -VM $StrVM04 -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrVM04 -Verbose -DisableBginfoExtension -AsJob


#스토리지 계정 생성
$storageAcct = New-AzStorageAccount -ResourceGroupName $RgName -Name $StAccName -Location $Location -Kind StorageV2 -SkuName Standard_GRS

# 파일 공유 생성
New-AzRmStorageShare -StorageAccount $storageAcct -Name $FileShareName -QuotaGiB 1024 | Out-Null

#키 확인
$keys=Get-AzStorageAccountKey -ResourceGroupName $RgName -AccountName $StAccName -ListKerbKey | awk "" '{print $2}' | awk 'NR==4'


#Bastion 생성
$bastion = New-AzBastion -ResourceGroupName $RgName -Name BastionHost01 -PublicIpAddress $StrBastion01PIP -VirtualNetwork $StrVnet01 -AsJob

#JumpBox 생성
$StrJumpBox = New-AzVMConfig -VMName $VMJump01 -VMSize "Standard_D1_v2"
$StrJumpBox = Set-AzVMOperatingSystem -VM $StrJumpBox -Windows -ComputerName $VMJump01 -Credential $Credential
$StrJumpBox = Add-AzVMNetworkInterface -VM $StrJumpBox -Id $StrJumpNIC.Id
$StrJumpBox = Set-AzVMSourceImage -VM $StrJumpBox -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $StrJumpBox -Verbose -AsJob


#IIS 설치(VM01, 02)
Set-AzVMExtension -ResourceGroupName $RgName -Publisher Microsoft.Compute -ExtensionType CustomScriptExtension -ExtensionName IIS -VMName $VM01Name -Location $Location -TypeHandlerVersion 1.8 -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' -AsJob
Set-AzVMExtension -ResourceGroupName $RgName -Publisher Microsoft.Compute -ExtensionType CustomScriptExtension -ExtensionName IIS -VMName $VM02Name -Location $Location -TypeHandlerVersion 1.8 -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' -AsJob



$JumpBox = $StrJMPPIP

#ELB-Public-IP 확인
Get-AzPublicIpAddress -Name $ELB01PIP -ResourceGroupName $RgName | Select IpAddress | awk 'NR==4'

# JumpBox PIP 확인
Get-AzPublicIpAddress -Name $JMPPIP -ResourceGroupName $RgName | Select IpAddress | awk 'NR==4'


# 부하 분산 확인
# http://ELB-Public-IP
# RDP 접속 확인
# mstsc ELB-Public-IP:30001
# ID=azureuser
# PW=Azurexptmxm123

# 스토리지 연결(네트워크 드라이브 Windows)
# 다시 부팅할 때 드라이브가 유지되도록 암호를 저장합니다.
echo "Copy to bottom command (2 lines) and paste Windows Server PowerShell"
echo "cmd.exe /C `"cmdkey /add:`"$StAccName$Fileurl`" /user:`"Azure\\$StAccName`" /pass:`"$keys`"`"";echo "New-PSDrive -Name Z -PSProvider FileSystem -Root `"\\$StAccName$Fileurl\$FileShareName`" -Persist"



















