#!/usr/bin/env bash
# Generate SSL certificates for all web services.
# Errata #9: Runs as a separate init container to avoid race conditions.
# Waits for CA to be healthy before generating certs.
set -euo pipefail

CA_DIR="/root/ca"
CA_DOMAIN="${CA_DOMAIN:-globalcert.com}"
CA_PASS="${CA_PASS:-password}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"
MAX_WAIT="${MAX_WAIT:-120}"

# Web service domains that need certificates
DOMAINS=(
  "dropbox.com"
  "pastebin.com"
  "redbook.com"
  "diagrams.net"
  "msftconnecttest.com"
)

echo "[cert-bootstrap] Waiting for CA PKI to be ready..."
elapsed=0
while [[ ! -f "${CA_DIR}/intermediate/certs/int.${CA_DOMAIN}.crt.pem" ]]; do
  if [[ "$elapsed" -ge "$MAX_WAIT" ]]; then
    echo "[cert-bootstrap] ERROR: CA PKI not ready after ${MAX_WAIT}s" >&2
    exit 1
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done
echo "[cert-bootstrap] CA PKI is ready."

mkdir -p "${OUTPUT_DIR}"

for domain in "${DOMAINS[@]}"; do
  echo "[cert-bootstrap] Generating certificate for ${domain}..."

  # Generate private key
  openssl genrsa -out "${CA_DIR}/intermediate/private/${domain}.key" 2048

  # Create CSR config
  cat > "/tmp/${domain}.cnf" <<EOF
[ req ]
default_bits = 2048
prompt = no
distinguished_name = req_dn
req_extensions = req_ext

[ req_dn ]
countryName = US
stateOrProvinceName = Oregon
localityName = Seattle
organizationName = ${domain}
commonName = ${domain}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${domain}
DNS.2 = www.${domain}
EOF

  # Generate CSR
  openssl req -new -sha256 \
    -key "${CA_DIR}/intermediate/private/${domain}.key" \
    -out "${CA_DIR}/intermediate/csr/${domain}.csr" \
    -config "/tmp/${domain}.cnf"

  # Sign with intermediate CA
  openssl ca -config "${CA_DIR}/intermediate/openssl_intermediate.cnf" \
    -extensions server_cert \
    -days 825 -notext -md sha512 \
    -in "${CA_DIR}/intermediate/csr/${domain}.csr" \
    -out "${CA_DIR}/intermediate/certs/${domain}.crt" \
    -passin pass:"${CA_PASS}" \
    -batch

  # Copy cert + key to shared output volume
  cp "${CA_DIR}/intermediate/certs/${domain}.crt" "${OUTPUT_DIR}/${domain}.crt"
  cp "${CA_DIR}/intermediate/private/${domain}.key" "${OUTPUT_DIR}/${domain}.key"

  echo "[cert-bootstrap] ${domain} certificate ready."
done

# Copy chain file for verification
cp "${CA_DIR}/intermediate/certs/chain.${CA_DOMAIN}.crt.pem" "${OUTPUT_DIR}/chain.pem"
cp "${CA_DIR}/certs/root.crt.pem" "${OUTPUT_DIR}/root.crt.pem"

echo "[cert-bootstrap] All web service certificates generated."
ls -la "${OUTPUT_DIR}/"
