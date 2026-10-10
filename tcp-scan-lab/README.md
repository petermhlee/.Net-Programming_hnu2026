# TCP Scan 실습 환경 (hostA → hostB)

2개의 컨테이너로 구성된 포트 스캔 실습 환경입니다. (ch05 목록화 연계)

- **hostA** (172.20.0.10) : 스캐너 — nmap 설치, `NET_RAW`/`NET_ADMIN` capability 부여
- **hostB** (172.20.0.20) : 대상 — SSH(22)·HTTP(80)·nc 리스너(9090)는 open, 8081은 iptables로 차단해 filtered 상태 시연

## 실행

```bash
cd tcp-scan-lab
docker compose up -d --build
docker exec -it hostA bash
```

## 실습 시나리오

### 1) TCP Connect Scan (`-sT`) — 권한 불필요
```bash
nmap -sT -p 22,80,81,9090,8081 172.20.0.20
```
OS의 `connect()` 시스템 콜로 3-way handshake를 완료하는 방식이라 일반 사용자 권한으로도 동작합니다.

### 2) TCP SYN Scan (`-sS`, half-open/스텔스 스캔) — raw socket 필요
```bash
nmap -sS -p 22,80,81,9090,8081 172.20.0.20
```
SYN만 보내고 ACK 전에 RST로 끊기 때문에 애플리케이션 로그에 완료된 연결로 남지 않습니다. raw socket을 직접 만들어야 해서 컨테이너에 `--cap-add=NET_RAW`가 없으면 "Operation not permitted" 오류가 납니다 (본 compose에는 이미 추가되어 있음).

### 3) 포트 상태 3종 비교
| 포트 | 상태 | 이유 |
|---|---|---|
| 22, 80, 9090 | open | 서비스가 실제로 LISTEN |
| 81 | closed | 아무 서비스도 없음 → RST 응답 |
| 8081 | filtered | hostB의 iptables가 SYN을 DROP → 응답 없음 |

### 4) 기타 스캔 기법 (선택)
```bash
nmap -sV -p 22,80 172.20.0.20        # 서비스/버전 탐지
nmap -sU -p 53,123 172.20.0.20       # UDP 스캔
nmap -sN -p 22,81 172.20.0.20        # NULL 스캔 (방화벽 우회 개념 설명용)
nmap -Pn 172.20.0.20                 # 호스트 탐지(ping) 생략하고 바로 포트 스캔
```

## 참고
- SYN 스캔에 raw socket 권한이 필요하다는 점과, 컨테이너 환경에서는 `--privileged` 대신 최소 권한 원칙에 따라 `--cap-add=NET_RAW`(및 필요 시 `NET_ADMIN`)만 부여하는 것이 권장된다는 점은 실제 nmap 컨테이너 배포 사례들에서 공통적으로 확인됩니다.
- 실습은 반드시 본인이 구성한 격리 네트워크(위 compose의 172.20.0.0/24) 안에서만 수행하고, 권한 없는 외부 호스트를 대상으로 스캔하지 않도록 안내해 주세요.
