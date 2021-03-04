# 목표
- External LB + Internal LB 환경 구축
- Bastion, Jumpbox를 통해서만 서버 접근
- Storage 사용하여 Internal VM에 연결
   
## 특이사항
- VM extension을 변수로 빼서 VM당 개별 설정 가능하도록 변경
- 스토리지의 access_key값을 export하여 자동으로 마운트되도록 extension에 적용

