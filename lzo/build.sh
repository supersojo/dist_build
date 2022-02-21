#!/bin/bash

set -e

LZO_MIRROR=http://www.oberhumer.com/opensource/lzo/download
LZO=lzo-2.10.tar.gz
LZO_SRC=lzo-2.10
LZO_INSTALL=install


export PATH=$PATH:/opt/gcc49-latest-linaro/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin

function download()
{
    if [ ! -e $LZO ]; then
        wget $LZO_MIRROR/$LZO
        tar zxvf $LZO
    fi
}

function build()
{
cd $LZO_SRC
./configure --prefix=$(pwd)/../$LZO_INSTALL --enable-static --target=arm-linux-gnueabi --host=arm-linux-gnueabi --disable-debug
make
make install
}

download

build
