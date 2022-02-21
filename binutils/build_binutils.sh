#!/usr/bin/bash

# exit on failure
set -e

#
# For self-build toolchain, first build the binutils
# Using exist compiler to build the binutils
# How to let self-build gcc use new bintuils?
# LD=$BINUILS_INSTALL_PPC/bin/powerpc-none-linux-gnu-ld.gold
#

BINUTILS_DIR=$(pwd)
BINUTILS_MIRROR=https://ftp.gnu.org/gnu/binutils
BINUTILS=binutils-2.37.tar.xz
BINUTILS_SRC=binutils-2.37
BINUTILS_BUILD=$BINUTILS_DIR/build

# all needed tools and libs into top install directory
BINUTILS_INSTALL=$(pwd)/../install


function download() {
    cd $BINUTILS_DIR
    if [[ ! -e $BINUTILS_DIR/$BINUTILS ]];then
       wget $BINUTILS_MIRROR/$BINUTILS 
    fi

    if [[ ! -d $BINUTILS_DIR/$BINUTILS_SRC ]];then
        tar Jxvf $BINUTILS
    fi

}

#
# --with-build-sysroot: used to find libraries for binutils exec file(such as as, ar...) to run (it's usefull for cross compile)
#
# To build binutils, we use existed compiler to complete. Let existed 'ld' do all things.
#
#ldd /opt/gcc10-aarch64/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-as
#	linux-vdso.so.1 (0x00007ffd373ed000)
#	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f7555677000)
#	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f7555485000)
#	/lib64/ld-linux-x86-64.so.2 (0x00007f75556a1000)
#
function config() {
    if [[ ! -d $BINUTILS_BUILD ]];then
       mkdir $BINUTILS_BUILD 
    fi

    cd $BINUTILS_BUILD
    ../$BINUTILS_SRC/configure --help
    #../$BINUTILS_SRC/configure --enable-64-bit-bfd --enable-targets=x86_64-none-linux-gnu --enable-gold --enable-initfini-array --enable-plugins --disable-doc --disable-gdb --disable-gdbtk --disable-nls --disable-tui --disable-werror --without-gdb --without-python --without-x --prefix=$BINUTILS_INSTALL 

    ../$BINUTILS_SRC/configure --enable-64-bit-bfd --enable-targets=x86_64-none-linux-gnu --enable-gold --enable-initfini-array --enable-plugins --disable-doc --disable-gdb --disable-gdbtk --disable-nls --disable-tui --disable-werror --without-gdb --without-python --without-x --prefix=$BINUTILS_INSTALL
}

# for powerpc
function config_ppc() {
    if [[ ! -d $BINUTILS_BUILD ]];then
       mkdir $BINUTILS_BUILD 
    fi

    cd $BINUTILS_BUILD
    ../$BINUTILS_SRC/configure --enable-64-bit-bfd --target=powerpc-none-linux-gnu --enable-gold --enable-initfini-array --enable-plugins --disable-doc --disable-gdb --disable-gdbtk --disable-nls --disable-tui --disable-werror --without-gdb --without-python --without-x --prefix=$BINUTILS_INSTALL 
}

function build() {
    if [[ ! -d $BINUTILS_BUILD ]];then
       mkdir $BINUTILS_BUILD 
    fi

    cd $BINUTILS_BUILD
    make && make install
}



# download binutils
download
# config for ppc
config_ppc
# build and install 
build
