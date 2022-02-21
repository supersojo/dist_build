#!/bin/bash

set -e

OPENVPN_MIRROR=https://swupdate.openvpn.org/community/releases
OPENVPN=openvpn-2.5.5.tar.gz
OPENVPN_SRC=openvpn-2.5.5
OPENVPN_INSTALL=install

OPENSSL_INSTALL=$(pwd)/../openssl/install
LZO_INSTALL=$(pwd)/../lzo/install


export PATH=$PATH:/opt/gcc49-latest-linaro/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin

function download()
{
if [ ! -e $OPENVPN ]; then
    wget $OPENVPN_MIRROR/$OPENVPN
    tar zxvf $OPENVPN
fi
}


function build()
{
cd $OPENVPN_SRC
./configure --target=arm-linux-gnueabi --host=arm-linux-gnueabi --prefix=$(pwd)/../$OPENVPN_INSTALL --enable-static --disable-shared --disable-debug --disable-plugins  --enable-static OPENSSL_LIBS="-L$OPENSSL_INSTALL/lib -lssl -lcrypto" OPENSSL_CFLAGS="-I$OPENSSL_INSTALL/include" LZO_CFLAGS="-I$LZO_INSTALL/include" LZO_LIBS="-L$LZO_INSTALL/lib -llzo2"


make LIBS="-all-static"
make install
}
