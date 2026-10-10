#!/bin/bash
# install-docker-engine.sh
# Ubuntu에서 구버전 Docker(docker.io 등)를 지우고
# Docker 공식 저장소를 통해 최신 Docker Engine + Compose 플러그인을 설치합니다.
#
# 사용법:
#   chmod +x install-docker-engine.sh
#   sudo ./install-docker-engine.sh

set -e

echo "=== 1/6. 기존 Docker 관련 패키지 제거 ==="
# 패키지가 없어도 스크립트가 멈추지 않도록 || true 처리
sudo apt-get remove -y docker docker.io docker-doc docker-compose podman-docker containerd runc || true

echo "=== 2/6. 사전 준비 도구 설치 ==="
sudo apt-get update
sudo apt-get install -y ca-certificates curl

echo "=== 3/6. Docker 공식 GPG 키 등록 ==="
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "=== 4/6. Docker apt 저장소 등록 ==="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== 5/6. 패키지 목록 갱신 및 Docker Engine 설치 ==="
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== 6/6. 설치 확인 ==="
docker --version
docker compose version

# sudo 없이 docker 명령을 쓰고 싶은 학생을 위한 안내 (선택 사항)
if ! groups "$USER" | grep -q docker; then
  echo
  echo "참고: 'sudo docker ...' 대신 'docker ...'만 쓰고 싶다면 아래 명령 실행 후"
  echo "      로그아웃/재로그인(또는 재부팅) 하세요."
  echo "      sudo usermod -aG docker \$USER"
fi

echo
echo "Docker Engine 설치가 완료되었습니다."
