#!/usr/bin/env bash
set -euo pipefail

eval "$(jq -r '@sh "CERT_PEM=\(.CERT_PEM) KEY_PEM=\(.KEY_PEM)"')"

CERT_FILE=$(mktemp)
KEY_FILE=$(mktemp)
PFX_FILE=$(mktemp)

echo "$CERT_PEM" > "$CERT_FILE"
echo "$KEY_PEM"  > "$KEY_FILE"

openssl pkcs12 -export \
  -keypbe NONE \
  -certpbe NONE \
  -nomaciter \
  -in "$CERT_FILE" \
  -inkey "$KEY_FILE" \
  -out "$PFX_FILE" \
  -passout pass:

BLOB=$(base64 -w0 < "$PFX_FILE")

jq -n --arg blob "$BLOB" '{"pfx_b64":$blob}'
