# 목표
- Peering + VPN(S2S) 연결

   
## 특이사항
- VPN 연동을 위한 Peering 설정 변경
- On-Premise 환경 추가
- LGW, VGW, VGW_Conncection
- On-Prem(가상), Azure 환경을 의존성 설정하지 않고 생성 시 자원이 꼬이는 문제 발생(Terraform 기본 의존성으로 해결안됨)
  -> vgw의 pip를 별도 생성 후 vgw, lgw 모듈에 depends_on = module.vgw_pip 설정함
  -> 결과 확인 필요

