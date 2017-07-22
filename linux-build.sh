#!/usr/bin/env bash

set -e

if [[ -z "$TOOLCHAIN_DIR" ]]; then
	TOOLCHAIN_DIR=/toolchain
fi

INFRASTRUCTURE=ftp://gcc.gnu.org/pub/gcc/infrastructure/

GMP_VER=6.1.0
ISL_VER=0.16.1
MPC_VER=1.0.3
MPFR_VER=3.1.4
GCC_VER=7.1.0
BINUTILS_VER=2.28

mkdir -p "$TOOLCHAIN_DIR"

export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

if [[ "$1" = 32 ]]; then
	export ABI=32
	export LD_LIBRARY_PATH="${TOOLCHAIN_DIR}/lib:${LD_LIBRARY_PATH}"
	export CFLAGS="-L${TOOLCHAIN_DIR}/lib -I${TOOLCHAIN_DIR}/include -m32"
	export CXXFLAGS="-L${TOOLCHAIN_DIR}/lib -I${TOOLCHAIN_DIR}/include -m32"
else
	export ABI=64
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

echo "Building binutils"
FILE="binutils-${BINUTILS_VER}.tar.bz2"
curl "https://ftp.gnu.org/gnu/binutils/${FILE}" -o "$FILE"
tar -xf "$FILE"
cd "binutils-${BINUTILS_VER}"
./configure --disable-debug --disable-dependency-tracking --prefix="$TOOLCHAIN_DIR" --with-gmp="$TOOLCHAIN_DIR" --with-mpfr="$TOOLCHAIN_DIR" --with-isl="${TOOLCHAIN_DIR}" --with-mpc="$TOOLCHAIN_DIR"
make
make install
