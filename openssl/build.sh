#!/bin/bash

set -e

OPENSSL_MIRROR=https://www.openssl.org/source
OPENSSL=openssl-1.1.1m.tar.gz
OPENSSL_SRC=openssl-1.1.1m
OPENSSL_INSTALL=install


export PATH=$PATH:/opt/gcc49-latest-linaro/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin


function download()
{
    if [ ! -e $OPENSSL ]; then
        wget $OPENSSL_MIRROR/$OPENSSL
        tar zxvf $OPENSSL
    fi
}

function build()
{
cd $OPENSSL_SRC
./Configure gcc -static -no-shared --prefix=$(pwd)/../$OPENSSL_INSTALL --cross-compile-prefix=arm-linux-gnueabi-
make
make install
}

download

build
