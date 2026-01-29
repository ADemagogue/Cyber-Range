#!/usr/bin/env bash
# Initialize the PKI (Root CA + Intermediate CA).
# Errata #7: Preserves exact path /root/ca/intermediate/certs/ expected by buildredteam.sh
# Errata #8: Uses faketime for certificate backdating (no system clock manipulation)
# Idempotent: skips if PKI already exists.
set -euo pipefail

CA_DIR="/root/ca"
CA_DOMAIN="${CA_DOMAIN:-globalcert.com}"
CA_COUNTRY="${CA_COUNTRY:-US}"
CA_STATE="${CA_STATE:-Oregon}"
CA_LOCALITY="${CA_LOCALITY:-Seattle}"
CA_ORG="${CA_ORG:-Global Certificate Authority}"
CA_PASS="${CA_PASS:-password}"
BACKDATE_DAYS="${BACKDATE_DAYS:-365}"

# Skip if already initialized
if [[ -f "${CA_DIR}/private/root.key.pem" && -f "${CA_DIR}/certs/root.crt.pem" && \
      -f "${CA_DIR}/intermediate/certs/int.${CA_DOMAIN}.crt.pem" ]]; then
  echo "[ca] PKI already initialized, skipping."
  exit 0
fi

echo "[ca] Initializing PKI structure..."

# Create directory structure
mkdir -p "${CA_DIR}"/{certs,crl,newcerts,private}
mkdir -p "${CA_DIR}/intermediate"/{certs,crl,csr,newcerts,private}
chmod 700 "${CA_DIR}/private" "${CA_DIR}/intermediate/private"

# Initialize databases
touch "${CA_DIR}/index.txt"
echo 1000 > "${CA_DIR}/serial"
touch "${CA_DIR}/intermediate/index.txt"
echo 1000 > "${CA_DIR}/intermediate/serial"
echo 1000 > "${CA_DIR}/crlnumber"
echo 1000 > "${CA_DIR}/intermediate/crlnumber"

# Prepare OpenSSL configs — substitute DOMAINNAME placeholder
cp /opt/ca-configs/openssl_root.cnf "${CA_DIR}/openssl_root.cnf"
cp /opt/ca-configs/openssl_intermediate.cnf "${CA_DIR}/intermediate/openssl_intermediate.cnf"
sed -i "s/DOMAINNAME/${CA_DOMAIN}/g" "${CA_DIR}/openssl_root.cnf"
sed -i "s/DOMAINNAME/${CA_DOMAIN}/g" "${CA_DIR}/intermediate/openssl_intermediate.cnf"

# Compute a backdated timestamp for faketime (absolute date string)
BACKDATE_OFFSET="$(date -d "-${BACKDATE_DAYS} days" '+%Y-%m-%d %H:%M:%S')"

echo "[ca] Generating Root CA key..."
openssl genrsa -aes256 -passout pass:"${CA_PASS}" -out "${CA_DIR}/private/root.key.pem" 4096
chmod 400 "${CA_DIR}/private/root.key.pem"

echo "[ca] Generating Root CA certificate (backdated ${BACKDATE_DAYS} days)..."
faketime "${BACKDATE_OFFSET}" openssl req -config "${CA_DIR}/openssl_root.cnf" \
  -key "${CA_DIR}/private/root.key.pem" \
  -new -x509 -days 7300 -sha512 \
  -extensions v3_ca \
  -out "${CA_DIR}/certs/root.crt.pem" \
  -passin pass:"${CA_PASS}" \
  -subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=${CA_ORG}/CN=${CA_ORG} Root CA"
chmod 444 "${CA_DIR}/certs/root.crt.pem"

# Alias for compatibility
ln -sf "${CA_DIR}/certs/root.crt.pem" "${CA_DIR}/certs/ca.${CA_DOMAIN}.crt.pem"
ln -sf "${CA_DIR}/private/root.key.pem" "${CA_DIR}/private/ca.${CA_DOMAIN}.key.pem"

echo "[ca] Generating Intermediate CA key..."
openssl genrsa -aes256 -passout pass:"${CA_PASS}" \
  -out "${CA_DIR}/intermediate/private/int.${CA_DOMAIN}.key.pem" 4096
chmod 400 "${CA_DIR}/intermediate/private/int.${CA_DOMAIN}.key.pem"

echo "[ca] Creating Intermediate CSR..."
faketime "${BACKDATE_OFFSET}" openssl req -config "${CA_DIR}/intermediate/openssl_intermediate.cnf" \
  -new -sha512 \
  -key "${CA_DIR}/intermediate/private/int.${CA_DOMAIN}.key.pem" \
  -out "${CA_DIR}/intermediate/csr/int.${CA_DOMAIN}.csr.pem" \
  -passin pass:"${CA_PASS}" \
  -subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=${CA_ORG}/CN=${CA_ORG} Intermediate CA"

echo "[ca] Signing Intermediate CA certificate..."
faketime "${BACKDATE_OFFSET}" openssl ca -config "${CA_DIR}/openssl_root.cnf" \
  -extensions v3_intermediate_ca \
  -days 3650 -notext -md sha512 \
  -in "${CA_DIR}/intermediate/csr/int.${CA_DOMAIN}.csr.pem" \
  -out "${CA_DIR}/intermediate/certs/int.${CA_DOMAIN}.crt.pem" \
  -passin pass:"${CA_PASS}" \
  -batch
chmod 444 "${CA_DIR}/intermediate/certs/int.${CA_DOMAIN}.crt.pem"

echo "[ca] Creating certificate chain file..."
cat "${CA_DIR}/intermediate/certs/int.${CA_DOMAIN}.crt.pem" \
    "${CA_DIR}/certs/root.crt.pem" \
    > "${CA_DIR}/intermediate/certs/chain.${CA_DOMAIN}.crt.pem"
chmod 444 "${CA_DIR}/intermediate/certs/chain.${CA_DOMAIN}.crt.pem"

echo "[ca] PKI initialization complete."
echo "[ca]   Root CA cert:         ${CA_DIR}/certs/root.crt.pem"
echo "[ca]   Intermediate CA cert: ${CA_DIR}/intermediate/certs/int.${CA_DOMAIN}.crt.pem"
echo "[ca]   Chain file:           ${CA_DIR}/intermediate/certs/chain.${CA_DOMAIN}.crt.pem"
