
## 현재 진행 상황
- Azure Portal (100%)
- Azure CLI (100%)
- Azure PowerShell (100%)
- Terraform (100%)

## 학습 내용
- VPN 생성 시 이용자에게 안내해줘야 할 내용과 범위를 알아본다.
    1. On-Premise 스위치와 VPN 장비에서의 라우팅 등의 설정(Azure VNet01, VNet02)
    2. On-Premise <-> Azure 환경간 내부 IP 중복되지 않게 설정해야 함
- 두 가상 네트워크 간 Peering에서 VPN 트래픽을 전달하기 위해 어떤 옵션이 있는지 알아본다.

    Peering 추가 시 [가상 네트워크 게이트웨이] 항목을 없음 → (원격) 가상 네트워크 게이트웨이 사용으로 바꿔야 한다.



## 주의 사항
Windows 서버인 경우

ICMP 허용

New-NetFirewallRule –DisplayName "Allow ICMPv4-In" –Protocol ICMPv4

IP 포워딩 허용(NVA에서 실행)

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name IpEnableRouter -Value 1
