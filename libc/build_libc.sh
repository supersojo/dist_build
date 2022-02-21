#!/usr/bin/bash

#
# build libc for use
#
# For simplicity just native build here

GLIBC_MIRROR=http://ftp.gnu.org/gnu/glibc
GLIBC=glibc-2.34.tar.xz

GLIBC_SRC=glibc-2.34

GLIBC_BUILD=$(pwd)/glibc_build

# binutils gcc all is here
GLIBC_INSTALL_DIR=$(pwd)/../install


# kernel headers
KERNEL_HEADERS=$(pwd)/../kernel_build/headers_install

function download() {
   if [[ ! -e $GLIBC ]];then
        wget $GLIBC_MIRROR/$GLIBC
   fi 

   if [[ ! -d $GLIBC_SRC ]];then
        tar Jxvf $GLIBC
   fi
}

function build_final() {
    if [[ ! -d $GLIBC_BUILD ]];then
        mkdir $GLIBC_BUILD
    fi
    if [[ ! -d $GLIBC_INSTALL_DIR ]];then
        mkdir $GLIBC_INSTALL_DIR
    fi

    cd $GLIBC_BUILD
    ../$GLIBC_SRC/configure --host=powerpc-none-linux-gnu --prefix=$GLIBC_INSTALL_DIR/powerpc-none-linux-gnu --with-headers=$KERNEL_HEADERS/include --without-selinux
    make
    make install 
}

function build_bootstrap() {
    if [[ ! -d $GLIBC_BUILD ]];then
        mkdir $GLIBC_BUILD
    fi
    if [[ ! -d $GLIBC_INSTALL_DIR ]];then
        mkdir $GLIBC_INSTALL_DIR
    fi

    cd $GLIBC_BUILD
    ../$GLIBC_SRC/configure --host=powerpc-none-linux-gnu --prefix=$GLIBC_INSTALL_DIR/powerpc-none-linux-gnu --with-headers=$KERNEL_HEADERS/include --without-selinux
    make install-bootstrap-headers=yes install-headers
    make csu/subdir_lib
    install csu/crt1.o csu/crti.o csu/crtn.o $GLIBC_INSTALL_DIR/powerpc-none-linux-gnu/lib 
    powerpc-none-linux-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $GLIBC_INSTALL_DIR/powerpc-none-linux-gnu/lib/libc.so
    touch $GLIBC_INSTALL_DIR/powerpc-none-linux-gnu/include/gnu/stubs.h
}


#download
# set PATH
export PATH=$PATH:${GLIBC_INSTALL_DIR}/bin
#build
