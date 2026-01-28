FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    docker.io \
    iproute2 \
    iptables \
    jq \
    net-tools \
    openssh-client \
    openssh-server \
    sshpass \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts (build context is project root)
COPY rts/scripts/ /opt/nrts/scripts/
COPY docker/nrts/entrypoint.sh /opt/nrts/entrypoint.sh
RUN chmod +x /opt/nrts/entrypoint.sh /opt/nrts/scripts/*.sh 2>/dev/null || true

ENTRYPOINT ["bash", "/opt/nrts/entrypoint.sh"]
