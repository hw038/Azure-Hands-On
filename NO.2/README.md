
## 현재 진행 상황
- Azure Portal (100%)
- Azure CLI (100%)
- Azure PowerShell (100%)
- Terraform (0%)

   
## 학습 목표
1. VMSS와 Load Balancer, Public IP의 관계
- 고가용성과 부하 분산의 조합을 통해 트래픽을 분산 처리하며 자원 사용량이 높은 VM은 Scale Out하게 된다.
- Public IP는 외부에서는 서비스를 이용하기 위한 주소이고, 내부적으로는 RDP와 같은 관리자용 접근 또한 가능하게 한다.

2. VMSS에서 Instance를 Scale Out할 때, 장단점
 - ![alt text](https://www.notion.so/No-2-Scale-Set-4cad96c4bd164c42b2427fa5cfd56230#7d2f06a19f6d40469ead7f0084e9d8dd)
  * 장점
   + 수평적 확산으로 지속적인 확장이 가능하고 분산 처리로 인해 장애 시에도 전면 장애의 가능성이 낮다.
  * 단점
   + 로드 밸런싱이 필요하고, 노드를 확장할수록 문제 발생의 잠재 원인 또한 늘어난다. 이런 관리 범위가 넓어짐에 따라 아키텍처에 대한 높은 이해도가 요구된다. 또한, 소프트웨어 가격이 Scale Up에 비해 비싸다는 단점도 있다.
  * 정리
   + 빅데이터의 데이터 마이닝이나 검색엔진 데이터 분석 처리 등을 대표하는 
   + OLAP(Online Analytical Processing) 애플리케이션 환경에서는 대량의 데이터 처리와 복잡한 쿼리가 이루어지기 때문에 Scale Out구성이 더 효율적이다.
   + 반대로 온라인 금융거래와 같이 워크플로우 기반에 빠르고 정확하면서 단순한 처리가   필요한 OLTP(Online Transaction Processing) 환경에서는 고성능의 Scale Up방식이 적합

## 주의 사항
1. VMSS를 LB하기 위해서는 LB가 기본이 아닌 표준이여야함
 - VMSS 만들면서 부하 분산 장치 생성하면 연결 가능
 - LB 인바운드 NAT 규칙을 별도로 추가하는 경우에는 제대로 적용이 되지않기 때문에 VMSS 생성 시 LB를 새로 생성하는 방법으로 해결
2. VMSS 생성 시 네트워크 보안 그룹은 기존 NSG를 선택할 수 없음(자동 생성)
 - CLI, PowerShell에서는 네트워크 보안 그룹이 자동 생성되지 않기 때문에 별도  설정없이 RDP연결 가능
 - 단, NSG가 생성되지 않기 때문에 별도 NSG 생성하여 관리 시 NSG만 생성 후 연결해야함
