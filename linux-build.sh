#!/usr/bin/env bash

set -e

if [[ -z "$TOOLCHAIN_DIR" ]]; then
	TOOLCHAIN_DIR=/toolchain
fi

GMP_VER=6.1.2
MPFR_VER=3.1.5
MPC_VER=1.0.3
ISL_VER=0.18
GCC_VER=7.2.0
BINUTILS_VER=2.29

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
curl "https://gmplib.org/download/gmp/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "gmp-${GMP_VER}"
./configure --prefix="$TOOLCHAIN_DIR" --enable-cxx
make
make check
make install
cd ..
rm -r "gmp-${GMP_VER}"

echo "Building MPFR"
FILE="mpfr-${MPFR_VER}.tar.bz2"
curl "https://ftp.gnu.org/gnu/mpfr/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "mpfr-${MPFR_VER}"
./configure --disable-dependency-tracking --prefix="$TOOLCHAIN_DIR"
make
make check
make install
cd ..
rm -r "mpfr-${MPFR_VER}"

echo "Building MPC"
FILE="mpc-${MPC_VER}.tar.gz"
curl "https://ftp.gnu.org/gnu/mpc/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "mpc-${MPC_VER}"
./configure --prefix="$TOOLCHAIN_DIR" --disable-dependency-tracking --with-gmp="$TOOLCHAIN_DIR" --with-mpfr="$TOOLCHAIN_DIR"
make
make check
make install
cd ..
rm -r "mpc-${MPC_VER}"

echo "Building ISL"
FILE="isl-${ISL_VER}.tar.bz2"
curl "http://isl.gforge.inria.fr/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
cd "isl-${ISL_VER}"
./configure --disable-dependency-tracking --disable-silent-rules --prefix="$TOOLCHAIN_DIR" --with-gmp=system --with-gmp-prefix="$TOOLCHAIN_DIR"
make check
make install
cd ..
rm -r "isl-${ISL_VER}"

echo "Building GCC"
FILE="gcc-${GCC_VER}.tar.gz"
curl "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/${FILE}" -o "$FILE"
tar -xf "$FILE"
rm "$FILE"
mkdir "gcc-${GCC_VER}/build"
cd "gcc-${GCC_VER}/build"
../configure --prefix="$TOOLCHAIN_DIR" --enable-languages=c,c++ --with-gmp="$TOOLCHAIN_DIR" --with-mpfr="$TOOLCHAIN_DIR" --with-isl="$TOOLCHAIN_DIR" --with-mpc="$TOOLCHAIN_DIR" --disable-werror --disable-multilib
make bootstrap
make install
cd ../..
rm -r "gcc-${GCC_VER}"

echo "Building binutils"
FILE="binutils-${BINUTILS_VER}.tar.bz2"
curl "https://ftp.gnu.org/gnu/binutils/${FILE}" -o "$FILE"
tar -xf "$FILE"
cd "binutils-${BINUTILS_VER}"
./configure --disable-debug --disable-dependency-tracking --prefix="$TOOLCHAIN_DIR" --with-gmp="$TOOLCHAIN_DIR" --with-mpfr="$TOOLCHAIN_DIR" --with-isl="${TOOLCHAIN_DIR}" --with-mpc="$TOOLCHAIN_DIR"
make
make install
cd ..
rm -r "binutils-${BINUTILS_VER}"
