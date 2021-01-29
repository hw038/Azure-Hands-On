
# CLI   
   
모든 구성에는 여러 가지 방법이 존재한다.
예 1) VM을 생성하면서 ELB, NSG, VNet, Subnet 등을 같이 생성
예 2) ELB, NSG, VNet, Subnet 등의 자원을 먼저 생성한 후 VM을 생성하면서 기 생성된 자원들에 연결
예 3) 예 2를 하고나서 제대로 연결되지 않는 부분들은 추후 수정
   
스크립트 언어(CLI, PowerShell)로 작성한 경우 서로 성격이 다르기 때문에 똑같은 방식으로 처리할 수 없음
   
## CLI 특징
   
### 개행 문자
- 윈도우(`) 리눅스(\)
   
### 동작 방식
- 1차원적으로 name위주로 운용하는 방식
- az 명령주체 행동
  * 명령 주체 : group, network vnet, vm, network nsg rule 등등
  * 행동 : create, show, list, delete 등등

### 장점
- 1명령 1실행으로 간결하다

### 단점
- config 운용이 불가능해 반복 작업에 취약하다.
- 예) NSG rule을 매번 만들어야 함
   
   
### 진행 방법
1. 자원명 변수에 저장
2. 그룹 및 자원 생성
3. VM 생성 후 자원에 연결 (ELB Backend, NAT 등등)
  

