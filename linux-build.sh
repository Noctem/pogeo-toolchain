#!/usr/bin/env bash

set -e

if [[ -z "$TOOLCHAIN_DIR" ]]; then
	TOOLCHAIN_DIR=/toolchain
fi

if [[ "$1" = 32 ]]; then
	export ABI=32
else
	export ABI=64
fi

INFRASTRUCTURE=ftp://gcc.gnu.org/pub/gcc/infrastructure/

GMP_VER=6.1.0
ISL_VER=0.16.1
MPC_VER=1.0.3
MPFR_VER=3.1.4
GCC_VER=6.3.0
OPENSSL_VER=1.0.2k

mkdir -p "$TOOLCHAIN_DIR"

export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

if [[ "$ABI" = 32 ]]; then
	export LD_LIBRARY_PATH="${TOOLCHAIN_DIR}/lib:${LD_LIBRARY_PATH}"
	export CFLAGS="-L${TOOLCHAIN_DIR}/lib -I${TOOLCHAIN_DIR}/include -m32"
	export CXXFLAGS="-L${TOOLCHAIN_DIR}/lib -I${TOOLCHAIN_DIR}/include -m32"
else
	export LD_LIBRARY_PATH="${TOOLCHAIN_DIR}/lib64:${TOOLCHAIN_DIR}/lib:${LD_LIBRARY_PATH}"
	export CFLAGS="-L${TOOLCHAIN_DIR}/lib64 -L${TOOLCHAIN_DIR}/lib -I${TOOLCHAIN_DIR}/include -m64"
	export CXXFLAGS="-L${TOOLCHAIN_DIR}/lib64 -L${TOOLCHAIN_DIR}/lib -I${TOOLCHAIN_DIR}/include -m64"
fi

echo "Building GMP"
FILE="gmp-${GMP_VER}.tar.bz2"
curl "${INFRASTRUCTURE}${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "gmp-${GMP_VER}"
./configure --prefix="$TOOLCHAIN_DIR" --enable-cxx
make
make check
make install
cd ..

echo "Building MPFR"
FILE="mpfr-${MPFR_VER}.tar.bz2"
curl "${INFRASTRUCTURE}${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "mpfr-${MPFR_VER}"
./configure --disable-dependency-tracking --prefix="$TOOLCHAIN_DIR"
make
make check
make install
cd ..

echo "Building MPC"
FILE="mpc-${MPC_VER}.tar.gz"
curl "${INFRASTRUCTURE}${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "mpc-${MPC_VER}"
./configure --prefix="$TOOLCHAIN_DIR" --disable-dependency-tracking --with-gmp="$TOOLCHAIN_DIR" --with-mpfr="$TOOLCHAIN_DIR"
make
make check
make install
cd ..


echo "Building ISL"
FILE="isl-${ISL_VER}.tar.bz2"
curl "${INFRASTRUCTURE}${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "isl-${ISL_VER}"
./configure --disable-dependency-tracking --disable-silent-rules --prefix="$TOOLCHAIN_DIR" --with-gmp=system --with-gmp-prefix="$TOOLCHAIN_DIR"
make check
make install

echo "Building GCC"
FILE="gcc-${GCC_VER}.tar.bz2"
curl "ftp://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VER}/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
mkdir "gcc-${GCC_VER}/build"
cd "gcc-${GCC_VER}/build"
../configure --prefix="$TOOLCHAIN_DIR" --enable-languages=c,c++ --with-gmp="$TOOLCHAIN_DIR" --with-mpfr="$TOOLCHAIN_DIR" --with-isl="$TOOLCHAIN_DIR" --with-mpc="$TOOLCHAIN_DIR" --disable-werror --disable-multilib
make bootstrap
make install
cd ../../

echo "Building OpenSSL"
FILE="openssl-${OPENSSL_VER}.tar.gz"
curl "https://www.openssl.org/source/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "openssl-${OPENSSL_VER}"
./config no-shared no-ssl2 no-ssl3 no-idea no-dtls1 no-npn no-psk no-srp no-ec2m no-weak-ssl-ciphers no-camellia no-cmac no-des no-dh no-dsa no-dtls no-ec no-ecdh no-ecdsa no-ec-nistp-64-gcc-128 no-engine no-heartbeats no-krb5 no-md2 no-md4 no-mdc2 no-whirlpool no-x509-verify no-comp -fPIC -I/usr/include --prefix="$TOOLCHAIN_DIR"
make depend
make install
cd ..
