#!/usr/bin/bash

#
# build gcc with custom glibc
#

# exit on failure
set -e

GCC_DIR=$(pwd)

# include the functions
. $GCC_DIR/build_gcc.sh

download

# build final gcc with libc
# need libc headers and start files and libc.so (You need provide them first)
build_final
