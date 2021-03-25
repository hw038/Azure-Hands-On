

# Terraform   
   
모든 구성에는 여러 가지 방법이 존재한다.
예 1) VM을 생성하면서 ELB, NSG, VNet, Subnet 등을 같이 생성
예 2) ELB, NSG, VNet, Subnet 등의 자원을 먼저 생성한 후 VM을 생성하면서 기 생성된 자원들에 연결
예 3) 예 2를 하고나서 제대로 연결되지 않는 부분들은 추후 수정
   
테라폼은 현상 유지라는 점에서 앞선 CLI, PowerShell과는 확연히 다르다.

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
- HCL

### 장점
- Azure에 국한된 것이 아닌 AWS, GCP, NCP, k8s 등 다양하게 지원한다.
- 상태를 유지하는 것이기 때문에 여러번 배포해도 동일 상태를 유지시키게 된다.
- 의존관계를 파악하기 때문에 리소스 정의 순서가 중요하지 않다.
  * 특별한 경우에는 depens_on을 통해 순서를 정리해줘야함
   
### 단점
- HCL과 테라폼 환경을 새로 배워야 한다.
   
   
### 진행 방법
1. 변수, 함수 사용의 절차와 비슷하게 진행
3. 리소스 동작 결과를 가지고 다른 모듈에서 사용 가능
  
### 느낀 점
- 리소스의 상태 '유지'하기 때문에 명령어 입력 방식에 비해 수정, 관리가 굉장히 용이하다.(멱등성)
- 아직 테라폼의 환경에 대해서 충분히 숙지하지 못했기 때문에 더 많은 공부가 필요하다.
- 더 잘 짜여진 구조로 설계해서 코딩하고 싶다.
  * 모듈, 배열, 반복문 사용을 통해 더 복잡하지만 재사용가능한 코드를 구현했다.
