FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    faketime \
    openssh-server \
    bash \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Copy CA configs (build context is project root)
COPY ca/openssl_root.cnf /opt/ca-configs/openssl_root.cnf
COPY ca/intermediate/openssl_intermediate.cnf /opt/ca-configs/openssl_intermediate.cnf

# Copy CA scripts and data
COPY docker/ca/init-pki.sh /opt/ca-scripts/init-pki.sh
COPY docker/ca/entrypoint.sh /opt/ca-scripts/entrypoint.sh
COPY ca/scripts/certmaker.sh /opt/ca-scripts/certmaker.sh
COPY ca/scripts/UScitystate.txt /opt/ca-data/UScitystate.txt
COPY ca/scripts/companytype.txt /opt/ca-data/companytype.txt

RUN chmod +x /opt/ca-scripts/*.sh

# SSH setup
RUN mkdir -p /run/sshd && \
    echo 'root:toor' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD test -f /root/ca/certs/root.crt.pem && \
      test -f /root/ca/intermediate/certs/int.${CA_DOMAIN:-globalcert.com}.crt.pem

ENTRYPOINT ["bash", "/opt/ca-scripts/entrypoint.sh"]
