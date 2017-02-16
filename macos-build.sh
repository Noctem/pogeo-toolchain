#!/usr/bin/env bash

set -e

OPENSSL_VER=1.0.2k

mkdir -p "/usr/local/openssl-static"

echo "Building OpenSSL"
FILE="openssl-${OPENSSL_VER}.tar.gz"
curl "https://www.openssl.org/source/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "openssl-${OPENSSL_VER}"
perl ./Configure --prefix=/usr/local/openssl-static no-shared no-ssl2 no-ssl3 no-idea no-dtls1 no-npn no-psk no-srp no-ec2m no-weak-ssl-ciphers no-camellia no-cmac no-des no-dh no-dsa no-dtls no-ec no-ecdh no-ecdsa no-ec-nistp-64-gcc-128 no-engine no-heartbeats no-krb5 no-md2 no-md4 no-mdc2 no-whirlpool no-x509-verify -fPIC no-comp darwin64-x86_64-cc
make depend
make install
cd ..

