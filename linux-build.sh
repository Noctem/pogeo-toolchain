#!/usr/bin/env bash

set -e

if [[ -z "$TOOLCHAIN_DIR" ]]; then
	TOOLCHAIN_DIR=/toolchain
fi

GMP_VER=6.1.2
MPFR_VER=4.0.0
MPC_VER=1.1.0
ISL_VER=0.18
GCC_VER=7.3.0
BINUTILS_VER=2.28.1

mkdir -p "$TOOLCHAIN_DIR"

echo "Downloading GCC"
FILE="gcc-${GCC_VER}.tar.gz"
curl "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/${FILE}" -o "$FILE"
tar -xf "$FILE"

echo "Downloading GMP"
FILE="gmp-${GMP_VER}.tar.bz2"
curl "https://gmplib.org/download/gmp/${FILE}" -o "$FILE"
tar -xf "$FILE"

echo "Downloading MPFR"
FILE="mpfr-${MPFR_VER}.tar.bz2"
curl "https://ftp.gnu.org/gnu/mpfr/${FILE}" -o "$FILE"
tar -xf "$FILE"

echo "Downloading MPC"
FILE="mpc-${MPC_VER}.tar.gz"
curl "https://ftp.gnu.org/gnu/mpc/${FILE}" -o "$FILE"
tar -xf "$FILE"

echo "Downloading ISL"
FILE="isl-${ISL_VER}.tar.bz2"
curl "http://isl.gforge.inria.fr/${FILE}" -o "$FILE"
tar -xf "$FILE"

echo "Downloading binutils"
FILE="binutils-${BINUTILS_VER}.tar.bz2"
curl "https://ftp.gnu.org/gnu/binutils/${FILE}" -o "$FILE"
tar -xf "$FILE"

[[ -z "$NOHASH" ]] && sha512sum -c SHA512SUMS
rm "gcc-${GCC_VER}.tar.gz" "gmp-${GMP_VER}.tar.bz2" "mpfr-${MPFR_VER}.tar.bz2" "mpc-${MPC_VER}.tar.gz" "isl-${ISL_VER}.tar.bz2" "binutils-${BINUTILS_VER}.tar.bz2"

echo "Symlinking dependencies into GCC's source dir"
cd "gcc-${GCC_VER}"
ln -s "../gmp-${GMP_VER}" gmp
ln -s "../mpfr-${MPFR_VER}" mpfr
ln -s "../mpc-${MPC_VER}" mpc
ln -s "../isl-${ISL_VER}" isl
ln -s "../binutils-${BINUTILS_VER}/bfd" bfd
ln -s "../binutils-${BINUTILS_VER}/binutils" binutils
ln -s "../binutils-${BINUTILS_VER}/gas" gas
ln -s "../binutils-${BINUTILS_VER}/gold" gold
ln -s "../binutils-${BINUTILS_VER}/gprof" gprof
ln -s "../binutils-${BINUTILS_VER}/ld" ld
ln -s "../binutils-${BINUTILS_VER}/libiberty" libiberty
ln -s "../binutils-${BINUTILS_VER}/opcodes" opcodes

echo "Building GCC and its dependencies"
mkdir "gcc-build"
cd "gcc-build"
../configure --prefix="$TOOLCHAIN_DIR" --disable-multilib --enable-languages=c,c++ --enable-checking=release
make bootstrap
make install-strip

echo "All components built. You may delete the source directories if you no longer need them."
