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

# only build pure gcc without libc
build_bootstrap
