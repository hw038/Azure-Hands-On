
# PowerShell   
   
모든 구성에는 여러 가지 방법이 존재한다.   
예 1) VM을 생성하면서 ELB, NSG, VNet, Subnet 등을 같이 생성   
예 2) ELB, NSG, VNet, Subnet 등의 자원을 먼저 생성한 후 VM을 생성하면서 기 생성된 자원들에 연결   
예 3) 예 2를 하고나서 제대로 연결되지 않는 부분들은 추후 수정   
   
스크립트 언어(CLI, PowerShell)로 작성한 경우 서로 성격이 다르기 때문에 똑같은 방식으로 처리할 수 없음

## 참고 레퍼런스
[링크](https://docs.microsoft.com/en-us/powershell/azure/?view=azps-5.4.0)

## PowerShell 버전 확인

```PSVersionTable.PSVersion```

## Azure PowerShell 버전 확인

```Get-InstalledModule -Name Az -AllVersions | Select-Object -Property Name, Version```


## PowerShell 특징
   
### 개행 문자
- ( ` )
   
### 동작 방식
- Config값을 별도 지정한 변수에 저장하여 활용
- 예) network interface config 값을 저장+생성 후 VM 생성 시 해당 config 값을 적용
- 동작-명령주체 -flag
  * 동작 : New, Set, Get, Add
  * 명령 주체 : AzResourceGroup, AzNetworkSecurityRuleConfig, AzVirtualNetwork 등등
  * flag : -Name, -ResourceGroupName, -Location 등등

### 장점
- Config값을 운영해 반복 작업 시 작업 효율이 높다.


### 단점
- name과 Config값을 혼용하기에 명령어의 flag 마다 필요한 값이 달라서 복잡하다
- Portal, CLI의 환경과 동일하게 작업 명령을 해도 비정상 동작이 발생해서 추후에 설정값을 변경해줘야하는 일이 있다.
   
   
### 진행 방법
1. 자원명 변수에 저장
2. 그룹 및 자원 생성
3. VM 생성 후 자원에 연결 (ELB Backend, NAT 등등)
  

