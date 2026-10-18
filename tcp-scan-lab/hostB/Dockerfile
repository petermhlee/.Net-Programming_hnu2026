FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    apache2 \
    netcat-openbsd \
    iptables \
    iproute2 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# TCP 22: SSH(open), TCP 80: HTTP(open), TCP 9090: nc 리스너(open), TCP 8081: iptables로 차단(filtered)
# UDP 9091: nc 리스너(open), UDP 8082: iptables로 차단(filtered)
EXPOSE 22 80 9090 8081
EXPOSE 9091/udp 8082/udp

ENTRYPOINT ["/entrypoint.sh"]
