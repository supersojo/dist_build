#!/usr/bin/bash

# exit on failure
set -e

GLIBC_DIR=$(pwd)
. $GLIBC_DIR/build_libc.sh

#
# build libc for use
#
# For simplicity just native build here

download

build_bootstrap
