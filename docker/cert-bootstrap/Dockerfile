FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Build context is project root
COPY docker/cert-bootstrap/generate-certs.sh /opt/generate-certs.sh
RUN chmod +x /opt/generate-certs.sh

ENTRYPOINT ["bash", "/opt/generate-certs.sh"]
