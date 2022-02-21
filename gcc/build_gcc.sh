#!/usr/bin/bash

#
# build gcc with custom glibc
#

GCC_MIRROR=https://gcc.gnu.org/pub/gcc/releases/gcc-11.2.0
GCC=gcc-11.2.0.tar.xz

# the directory that store gcc tarball 
GCC_DIR=$(pwd)

# only extract firectory name, not path
GCC_SRC=gcc-11.2.0
GCC_BUILD=$GCC_DIR/build

GCC_INSTALL_DIR=$(pwd)/../install
GLIBC_INSTALL_DIR=$GCC_DIR/../libc_build/install

# the directory that store dependent libs, such as gmp, mpfr, mpc ...
DEPENDENCIES_DIR=$(pwd)/dependencies/install

BINUTILS_PREFIX=powerpc-none-linux-gnu-
BINUTILS_INSTALL_PPC=$(pwd)/../binutils_build/install_ppc

# not a good idea
# We should copy binutils into install directory of gcc
# https://gcc.gnu.org/install/build.html
function set_binutils()
{
    AS=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}as
    AR=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}ar
    LD=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}ld.gold  
    NM=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}nm
    READELF=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}readelf
    SIZE=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}size
    STRIP=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}strip
    RANLIB=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}ranlib
    STRINGS=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}strings
    OBJCOPY=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}objcopy
    OBJDUMP=${BINUTILS_INSTALL_PPC}/bin/${BINUTILS_PREFIX}objdump

    export AS AR LD NM READELF SIZE STRIP RANLIB STRINGS OBJCOPY OBJDUMP
}

function download() {
    cd $GCC_DIR
    if [[ ! -e $GCC_DIR/$GCC ]];then
        wget $GCC_MIRROR/$GCC
    fi

    if [[ ! -d $GCC_SRC ]];then
        tar Jxvf $GCC
    fi
}

function build_bootstrap() {
    # prepare build directory
    if [[ ! -d $GCC_BUILD ]];then
        mkdir $GCC_BUILD
    fi

    cd $GCC_BUILD

    # build
    ../$GCC_SRC/configure --target=powerpc-none-linux-gnu --prefix=$GCC_INSTALL_DIR \
        --with-gmp=$DEPENDENCIES_DIR/gmp --with-mpfr=$DEPENDENCIES_DIR/mpfr \
        --with-mpc=$DEPENDENCIES_DIR/mpc --with-isl=$DEPENDENCIES_DIR/isl \
        --disable-multilib  --without-headers \
        --enable-languages=c,c++ -v
    make all-gcc
    make install-gcc

}

# no need to reconfigure
function build_final() {
    cd $GCC_BUILD
    make all-target-libgcc
    make install-target-libgcc
}

#download

#build_bootstrap
#build_final
