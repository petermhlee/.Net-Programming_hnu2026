#!/bin/bash
set -e

# --- open 포트 구성 ---
service ssh start                 # 22/tcp : open
service apache2 start             # 80/tcp : open
nohup nc -lk 9090 >/dev/null 2>&1 &   # 9090/tcp : open (단순 리스너)

# --- filtered 포트 구성 ---
# 8081/tcp 로 들어오는 SYN을 전부 폐기 → nmap 결과가 "filtered"로 표시됨
# (closed 포트는 별도 설정 없이 비워둔 포트, 예: 81/tcp 를 스캔하면 됨)
iptables -A INPUT -p tcp --dport 8081 -j DROP

echo "[hostB] 서비스 기동 완료: 22(open), 80(open), 9090(open), 8081(filtered)"

# 컨테이너 유지
tail -f /dev/null
