#!/bin/sh
# Called by the entrypoints before Apache starts. Makes a self-signed certificate for editors.eol.org
# if the certs folder (HTTPS_CERTS_PATH in .env, mounted at /etc/apache2/certs) has none.
# Cloudflare's SSL mode "Full" accepts a self-signed certificate; "Full (strict)" needs a Cloudflare Origin
# (or other trusted) certificate: put it in the same 2 files and restart web. An existing pair is never touched.
D=/etc/apache2/certs
CRT=$D/editors.eol.org.crt
KEY=$D/editors.eol.org.key
mkdir -p "$D"
if [ -s "$CRT" ] && [ -s "$KEY" ]; then
  echo "HTTPS certificate: $(openssl x509 -in "$CRT" -noout -subject -enddate | tr '\n' ' ')"
elif [ -e "$CRT" ] || [ -e "$KEY" ]; then
  echo "ERROR: only one of editors.eol.org.crt / .key is in the certs folder; add the other (or remove both to get a self-signed pair)" >&2
  exit 1
else
  umask 077
  openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -subj "/CN=editors.eol.org" \
    -addext "subjectAltName=DNS:editors.eol.org" -keyout "$KEY" -out "$CRT" 2>/dev/null \
    || { echo "ERROR: could not create a self-signed certificate in $D" >&2; exit 1; }
  chmod 600 "$KEY"; chmod 644 "$CRT"
  echo "HTTPS certificate: created a self-signed one for editors.eol.org (10 years)"
fi
