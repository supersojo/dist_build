#!/bin/bash

# exit on error
set -e

PYTHON_MIRROR=https://www.python.org/ftp/python/2.7.16
PYTHON=Python-2.7.16.tgz
PYTHON_SRC=Python-2.7.16
PYTHON_INSTALL=install

export PATH=$PATH:/opt/gcc49-latest-linaro/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin/
export HOST_ARCH=arm-linux-gnueabi
export TOOL_PREFIX=$HOST_ARCH
export CXX=$TOOL_PREFIX-g++
export CPP="$TOOL_PREFIX-g++ -E"
export AR=$TOOL_PREFIX-ar
export RANLIB=$TOOL_PREFIX-ranlib
export CC=$TOOL_PREFIX-gcc
export LD=$TOOL_PREFIX-ld
export READELF=$TOOL_PREFIX-readelf
export LDLAST="-lgcov"

function download()
{
    if [ ! -e $PYTHON ]; then
        wget $PYTHON_MIRROR/$PYTHON
        tar zxvf $PYTHON
    fi
}


function build()
{
cd $PYTHON_SRC
./configure --host=$HOST_ARCH --target=$HOST_ARCH --build=x86_64-pc-linux-gnu --prefix=$(pwd)/../$PYTHON_INSTALL --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes --enable-shared  --with-zlib-dir=/usr/lib64 --with-ensurepip=yes --enable-optimization
make BLDSHARED="$TOOL_PREFIX-gcc -shared" CROSS-COMPILE=$TOOL_PREFIX- CROSS_COMPILE_TARGET=yes
sudo make install BLDSHARED="$TOOL_PREFIX-gcc -shared" CROSS-COMPILE=$TOOL_PREFIX- CROSS_COMPILE_TARGET=yes prefix=$(pwd)/../$PYTHON_INSTALL
}

download

build

# note
# Finally build phase will fail because it will call compiled gcc appearently. Ignoring
