
## 현재 진행 상황
- Azure Portal (100%)
- Azure CLI (100%)
- Azure PowerShell (100%)
- Terraform (0%)

## 학습 목표
- 참고 자료 : [link](https://docs.microsoft.com/ko-kr/azure/virtual-network/tutorial-create-route-table-portal#route-traffic-through-an-nva)
- Peering을 사용하여 두 가상 네트워크를 연결한다.

    Peering을 각 VM의 IP 그대로 손쉽게 연결이 가능하다.

    마이크로소프트 백본 인프라를 통해 라우팅하므로 공용 인터넷 사용하지 않음
    데이터 규제가 엄격한 경우 유용하다.

- 연결된 가상 네트워크에서 Route Table을 사용하여 특정 Appliance로 트래픽을 전달한다.

    Route Table 을 사용하는 이유

    - Route Table의 경우 같은 가상 네트워크 내에 있는 서브넷-서브넷 간에 트래픽을 라우팅하는 역할을 수행한다.
    - NVA를 방화벽으로 두고 사용할 경우 보안이 높다.
    
    같은 가상 네트워크 내에 서브넷간 통신에 사용 시

    ![alt text](/NO.4/image/NO.4_같은_가상_네트워크_내_서브넷간_통신.png)

    첫 번째 홉은 10.0.2.4이고 NVA의 개인 IP 주소임을 알 수 있습니다. 두 번째 홉은 myVmPrivate VM의 개인 IP 주소입니다. 10.0.1.4에 있습니다. 이전에 경로를 myRouteTablePublic 경로 테이블에 추가하여 공용 서브넷에 연결했습니다. 이에 따라 Azure에서 NVA를 통해 트래픽을 보냈지만, 프라이빗 서브넷으로는 직접 보내지 않고 NVA를 통해 전달된다.


    확인 방법

    - VM→네트워크→NIC→유효 경로
## 주의 사항
1. ICMP 허용(Windows Server 환경일 시)

New-NetFirewallRule –DisplayName "Allow ICMPv4-In" –Protocol ICMPv4

2. IP 포워딩 허용(NVA에서 실행)

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name IpEnableRouter -Value 1
