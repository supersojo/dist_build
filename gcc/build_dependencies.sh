#!/usr/bin/bash

# exit on failure
set -e

#
# This script is used to download and build gcc dependent libraries in the calling directory
# So if you call this script in ~/somedir then all dependencies will be in ~/somedir/dependencies
# All build lib files are in ~/somdir/dependencies/install 
#
# cd ~/somedir
# ./build_dependencies.sh

DEPENDENCIES_MIRROR=https://gcc.gnu.org/pub/gcc/infrastructure

DEPENDENCIES_DIR=$(pwd)/dependencies
DEPENDENCIES_INSTALL_DIR=$(pwd)/dependencies/install

GMP=gmp-6.2.1.tar.bz2
MPFR=mpfr-4.1.0.tar.bz2
MPC=mpc-1.2.1.tar.gz
ISL=isl-0.24.tar.bz2

GMP_SRC=gmp-6.2.1
MPFR_SRC=mpfr-4.1.0
MPC_SRC=mpc-1.2.1
ISL_SRC=isl-0.24

ZSTD_MIRROR=https://github.com/facebook/zstd/archive/refs/tags
ZSTD=v1.5.0.tar.gz
ZSTD_SRC=zstd-1.5.0

# maybe more libraries needed time by time



# use how many core to build the lib
THREADS=1

dependencies=($GMP $MPFR $MPC $ISL)

# the src directory that be extract, must match package aboves
dependencies_srcs=($GMP_SRC $MPFR_SRC $MPC_SRC $ISL_SRC)

# extrac download lib
function extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xvjf $1    ;;
            *.tar.gz)    tar xvzf $1    ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xvf $1     ;;
            *.tbz2)      tar xvjf $1    ;;
            *.tgz)       tar xvzf $1    ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "I don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}


function download() {
    if [[ ! -d $DEPENDENCIES_DIR ]]; then
        mkdir $DEPENDENCIES_DIR
        echo -e "Prepare $DEPENDENCIES_DIR"
    else
        echo -e "$DEPENDENCIES_DIR is ready!"
    fi

    cd $DEPENDENCIES_DIR 

    for package in ${dependencies[*]}; do
        if [[ ! -e $package ]];then
            wget $DEPENDENCIES_MIRROR/$package
        fi

        extract $package
    done

    # zstd
    wget $ZSTD_MIRROR/$ZSTD
    extract $ZSTD

    cd -
}

mkdircd () { 
    mkdir -p "$@" && eval cd "\"\$$#\""; 
}
function build_1() {
    # create install directory if it's not exist
    if [[ ! -d $DEPENDENCIES_INSTALL_DIR ]];then
        mkdir $DEPENDENCIES_INSTALL_DIR
    fi

    if [[ ! -d $DEPENDENCIES_DIR/gmp-6.2.1/build ]];then
        cd $DEPENDENCIES_DIR/gmp-6.2.1
        mkdircd build
        ../configure --prefix=$DEPENDENCIES_INSTALL_DIR/gmp
        make -j $THREADS && make check && make install
    else
        echo -e "gmp is ready"
    fi


    if [[ ! -d $DEPENDENCIES_DIR/mpfr-4.1.0/build ]];then
        cd $DEPENDENCIES_DIR/mpfr-4.1.0
        mkdircd build
        ../configure --prefix=$DEPENDENCIES_INSTALL_DIR/mpfr
        make -j $THREADS && make install
    else
        echo -e "mpfr is ready"
    fi


    if [[ ! -d $DEPENDENCIES_DIR/mpc-1.2.1/build ]];then
        cd $DEPENDENCIES_DIR/mpc-1.2.1
        mkdircd build
        ../configure --with-gmp=$DEPENDENCIES_INSTALL_DIR/gmp --with-mpfr=$DEPENDENCIES_INSTALL_DIR/mpfr --prefix=$DEPENDENCIES_INSTALL_DIR/mpc
        make -j $THREADS && make install
    else
        echo -e "mpfr is ready"
    fi
}


function build() {
    # create install directory if it's not exist
    if [[ ! -d $DEPENDENCIES_INSTALL_DIR ]];then
        mkdir $DEPENDENCIES_INSTALL_DIR
    fi

    for lib in ${dependencies_srcs[*]}; do

        if [[ ! -d $DEPENDENCIES_DIR/$lib/build ]];then
            cd $DEPENDENCIES_DIR/$lib
            mkdircd build

            # configure
            # =~ for regex but not use parentheses
            if [[ "$lib" =~ gmp* ]];then
                ../configure --prefix=$DEPENDENCIES_INSTALL_DIR/gmp
            fi

            if [[ "$lib" =~ mpfr* ]];then
                ../configure --prefix=$DEPENDENCIES_INSTALL_DIR/mpfr
            fi
            
            if [[ "$lib" =~ mpc* ]];then
                ../configure --with-gmp=$DEPENDENCIES_INSTALL_DIR/gmp --with-mpfr=$DEPENDENCIES_INSTALL_DIR/mpfr --prefix=$DEPENDENCIES_INSTALL_DIR/mpc
            fi

            if [[ "$lib" =~ isl* ]];then
                ../configure --prefix=$DEPENDENCIES_INSTALL_DIR/isl
            fi

            # make and install
            if [[ "$lib" =~ gmp* ]];then
                make -j $THREADS && make check && make install
            else
                make -j $THREADS && make install
            fi
        else
            echo -e "$lib is ready"
        fi

    done

    # zstd
    cd $DEPENDENCIES_DIR/$ZSTD_SRC
    make -j $THREADS && make install prefix=$DEPENDENCIES_INSTALL_DIR/zstd
}

# remove all libraries files that extract and only reserve install files and tarballs 
function clean() {
    for lib in ${dependencies_srcs[*]}; do
            rm $DEPENDENCIES_DIR/$lib -rf
    done
}

usage() { 
    echo "Usage: $0 [-h] [-d] [-b] [-c]" 1>&2
cat << EOF
    -h for help
    -d download only
    -b for download and build
    -c for clean
EOF
    exit 1; 
}

# main entry
while getopts "hdbc" arg; do
    case "${arg}" in
        d)
            download
            ;;
        b)
            build
            ;;
        c)
            clean
            ;;
        *)
            usage
            ;;
    esac
done
