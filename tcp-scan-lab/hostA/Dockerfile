FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    nmap \
    iputils-ping \
    netcat-openbsd \
    tcpdump \
    iproute2 \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# 컨테이너를 계속 띄워두고 docker exec로 접속해서 실습
CMD ["sleep", "infinity"]
