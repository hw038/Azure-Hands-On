# 목표
- Peering + VPN(S2S) 연결

   
## 특이사항
- VPN 연동을 위한 Peering 설정 변경
- On-Premise 환경 추가
- LGW, VGW, VGW_Conncection

## 문제 및 해결
문제1 : On-Prem(가상), Azure 환경을 의존성 설정하지 않고 생성 시 자원이 꼬이는 문제 발생
  - 원인 : Terraform 기본 의존성으로 해결되지 않는 의존성
  - 해결 : vgw의 pip를 별도 생성 후 vgw, lgw 모듈에 depends_on = module.vgw_pip 설정함
   
문제2 : LGW에 Gateway address 입력 시 NULL값인 문제
  - 원인 : VGW의 Public IP를 생성한 직후의 pip의 address는 null값이기 때문에 빈값으로 인식하여 에러 발생
  - 테스트 : terraform apply 1회 더 진행하면 LGW 생성 및 VGW connection까지 진행됨(VGW pip의 address가 발급된 이후이기 때문에)
  - 근본적인 원인 : Public IP가 Dynamic인 경우 리소스에 할당되어야 address가 발급됨.
  - 해결 : data source를 통해서 vgw 생성 완료 후 data.public_ip 를 통해 데이터 output하여 정상 동작함을 확인
  
