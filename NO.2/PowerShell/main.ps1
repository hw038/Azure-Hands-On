$RgName="Hands-On-2-PS"
$Location="eastus"
$Vnet01Name="Hands-On-2-VNet01"
$Subnet01Name="Hands-On-2-Subnet01"
$NSG01Name="Hands-On-2-NSG01"
$ELB01Name="Hands-On-2-ELB01"
$ELB01PIP="ELB01PIP"
$ELB01BkPool01="ELB01BackPool01"
$ELB01HTTPProbe="Health80Probe"
$ELB01Rule="Hands-On-2-ELB0180"
$ELB01NAT01="VMSSRDP"
$VMSSName="Hands-On-2-VMSS"
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

#계정 정보 세팅
$Credential = New-Object System.Management.Automation.PSCredential ($ID, $PW);

New-AzVmss `
  -ResourceGroupName $RgName `
  -UpgradePolicyMode "Automatic" `
  -VMScaleSetName $VMSSName `
  -Location $Location `
  -VirtualNetworkName $Vnet01Name `
  -SubnetName $Subnet01Name `
  -PublicIpAddressName $ELB01PIP `
  -LoadBalancerName $ELB01Name `
	-SecurityGroupName $NSG01Name `
  -Credential $Credential


# 상태 프로브 생성
$StrELB = Get-AzLoadBalancer -Name $ELB01Name
$Probe = Add-AzLoadBalancerProbeConfig -Name $ELB01HTTPProbe -LoadBalancer $StrELB -Protocol "http" -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -RequestPath /
$Probe = Get-AzLoadBalancerProbeConfig -Name $ELB01HTTPProbe -LoadBalancer $StrELB
slb = Set-AzLoadBalancerRuleConfig `
	-LoadBalancer $StrELB `
	-Name $ELB01Rule `
	-Probe $Probe `
	-Protocol "tcp" `
	-FrontendIpConfiguration $frontend `
	-FrontendPort 80 `
	-BackendPort 80 `
	-BackendAddressPool $backendAddressPool
slb | Set-AzLoadBalancer

#LB Rule에 상태 프로브 연결

$vmss = Get-AzVmss `
            -ResourceGroupName $RgName `
            -VMScaleSetName $VMSSName

$hostname = "$"+"env"+":"+"computername"
$settings = @{
          commandToExecute = "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path C:\inetpub\wwwrot\Default.htm -Value $hostname"
        }

Add-AzVmssExtension `
	-Publisher Microsoft.Compute `
	-Type CustomScriptExtension `
	-Name IIS `
	-VirtualMachineScaleSet $vmss `
	-TypeHandlerVersion 1.8 `
	-Setting $settings

Update-AzVmss `
    -ResourceGroupName $RgName `
    -Name $VMSSName `
    -VirtualMachineScaleSet $vmss

# 인스턴스 확인용
#Get-AzVmssVM -ResourceGroupName $RgName -VMScaleSetName $VMSSName -InstanceId "3"

# Get the load balancer object
$lb = Get-AzLoadBalancer -ResourceGroupName $RgName -Name $ELB01Name

# View the list of inbound NAT rules
Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $lb | Select-Object Name,Protocol,FrontEndPort,BackEndPort

Get-AzPublicIpAddress -ResourceGroupName $RgName -Name $ELB01PIP | Select IpAddress


echo "접속 확인(계정)"
echo "ID=azureuser"
echo "PW=Azurexptmxm123"
