FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    bash \
    iproute2 \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["bash", "/opt/entrypoint.sh"]
