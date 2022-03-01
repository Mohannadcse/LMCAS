#!/bin/bash
set -ex

export LLVM_VERSION=12
export CC=/usr/local/bin/clang
export CXX=/usr/local/bin/clang++
export LLVM_CONFIG_BINARY=/usr/local/bin/llvm-config
export LLVM_LINK_NAME=llvm-link
export LLVM_AR_NAME=llvm-ar
export LLVM_COMPILER=clang

# wllvm-sanity-checker

ROOTDIR=$(pwd)

echo "Installing WLLVM" 
pip3 install -U lit tabulate wllvm

echo "Building Neck Identification" 
    pushd neck-identification
    ./build.sh
    popd

# collect all binaries here
mkdir -p $ROOTDIR/bin

echo "Building Partial Interpretation"
echo "Installing klee-uclibc"
    git clone --depth 1 https://github.com/klee/klee-uclibc.git || true
    pushd klee-uclibc
    ./configure --make-llvm-lib --with-llvm-config=/usr/local/bin/llvm-config
    make -j $(nproc)
    popd

echo "Building KLEE" 
    pushd partial-interpretation
    mkdir -p build
    cd build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX:PATH=$ROOTDIR \
        -DENABLE_SOLVER_Z3=ON  \
        -DENABLE_POSIX_RUNTIME=ON  \
        -DENABLE_UNIT_TESTS=OFF \
        -DENABLE_SYSTEM_TESTS=OFF \
        -DENABLE_KLEE_UCLIBC=ON   \
        -DLLVM_CONFIG_BINARY=$LLVM_CONFIG_BINARY \
        -DLLVMCC=$CC \
        -DLLVMCXX=$CXX \
        -DKLEE_UCLIBC_PATH=$ROOTDIR/klee-uclibc
    make -j $(nproc)
    make install
    echo "Klee binary installed in ${ROOTDIR}/bin"
    popd

echo "Building LLVM Simplification Passes"
    pushd LLVM_Passes
    mkdir -p build
    cd build
    cmake ..
    make -j $(nproc)
    popd

# for recognizing the `libLLVM-12.so` 
ldconfig

# for avoiding memory issue while running phasar
ulimit -s 16777216

