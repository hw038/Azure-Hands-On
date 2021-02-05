

# PowerShell   
   
모든 구성에는 여러 가지 방법이 존재한다.
예 1) VM을 생성하면서 ELB, NSG, VNet, Subnet 등을 같이 생성
예 2) ELB, NSG, VNet, Subnet 등의 자원을 먼저 생성한 후 VM을 생성하면서 기 생성된 자원들에 연결
예 3) 예 2를 하고나서 제대로 연결되지 않는 부분들은 추후 수정
   
스크립트 언어(CLI, PowerShell)로 작성한 경우 서로 성격이 다르기 때문에 똑같은 방식으로 처리할 수 없음

## 참고 레퍼런스
[링크](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## terraform 설치

[링크](https://www.terraform.io/downloads.html)   
   
작업 환경에 맞는 terraform 설치

Windows의 경우
terraform.exe 파일의 위치 경로 : %PATH% (C:\Users\user)

## 사용   
   
1. az login
 - 애저에 실행할 수 있도록 로그인
   
2. vscode를 통해 해당 소스 폴더를 오픈한 후 터미널 창에서 terraform 명령어 입력
 - ```terraform init```
   * 현재 경로를 테라폼 환경으로 초기화
 - ```terraform plan```
   * 소스의 내용이 배포될 때 변경되는 내용들 확인 및 유효한지 검토
 - ```terraform apply```
   * 소스의 내용대로 배포
   
## 버전 확인
```terraform version```

## Terraform 특징

### 동작 방식
- HCL로 
- 예) network interface config 값을 저장+생성 후 VM 생성 시 해당 config 값을 적용
- 동작-명령주체 -flag
  * 동작 : New, Set, Get, Add
  * 명령 주체 : AzResourceGroup, AzNetworkSecurityRuleConfig, AzVirtualNetwork 등등
  * flag : -Name, -ResourceGroupName, -Location 등등

### 장점
- Azure에 국한된 것이 아닌 AWS, GCP, NCP, k8s 등 다양하게 지원한다.
- 상태를 유지하는 것이기 때문에 여러번 배포해도 동일 상태를 유지시키게 된다.
- 의존관계를 파악하기 때문에 리소스 정의 순서가 중요하지 않다.
   
### 단점
- HCL과 테라폼 환경을 새로 배워야 한다.
   
   
### 진행 방법
1. 변수에 저장된 자원명대로 그룹 및 자원 생성
3. VM 생성 후 자원에 연결 (ELB Backend, NAT 등등)
  
### 느낀 점
- 리소스의 상태 '유지'이기 때문에 명령어 입력 방식에 비해 수정, 관리가 굉장히 용이하다.
- 아직 테라폼의 환경에 대해서 충분히 숙지하지 못했기 때문에 더 많은 공부가 필요하다.
- 더 잘 짜여진 구조로 설계해서 코딩하고 싶다.
