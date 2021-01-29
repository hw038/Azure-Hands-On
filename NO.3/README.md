
## 현재 진행 상황
- Azure Portal (100%)
- Azure CLI (100%)
- Azure PowerShell (100%)
- Terraform (0%)

## 학습 목표
1. Internal Loadbalancer의 용도를 알아본다.
    - 외부와의 접속을 차단하고 내부 망으로만 운영 시에 사용한다.
    - Subnet02를 DB등과 같이 중요 자원을 배치하면 보안성이 높아질 것으로 보인다.
    - 예시
    ![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f946921f-6b9b-475a-9d26-f2b1b4cb1cf5/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f946921f-6b9b-475a-9d26-f2b1b4cb1cf5/Untitled.png)
2. Subnet01과 Subnet02의 직접 통신은 차단한다.
    - ILB를 통해 접속
3. Subnet01의 가상 머신은 InternalLB01을 통해서만 Subnet02와 통신한다.
    - ILB를 통해 접속
4. Azure Storage Account의 File Share 기능을 가상 머신에 적용시켜 본다.
    - 적용하여 한 디렉터리를 공유하는 동작 확인
5. JumpBox와 Bastion host의 용도에 대해 알아본다.
    - 둘다 내부 망에 관리자가 따로 접속하기 위한 것으로 아래와 같다.
    - Bastion host : VNet에 연결해 **Azure Portal을 통해** 바로 VM에 접속하기 위한 방법
    - JumpBox : 내부 VM에 접속하기 위한 DMZ VM
    - 1) Bastion→JumpBox→VM03 = 가능
    - 2) Bastion→VM03 = 가능
## 주의 사항
1. Storage FileShare의 경우 extension을 활용하여 자동 마운트하고싶었지만 해당 부분에 어려움이 있어 마운트할 수 있는 스크립트를 자동으로 표시
 
