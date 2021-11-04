#!/bin/bash
set -ex

export LLVM_VERSION=10
export CC=/usr/bin/clang-$LLVM_VERSION
export CXX=/usr/bin/clang++-$LLVM_VERSION
export LLVM_CONFIG_BINARY=/usr/bin/llvm-config-$LLVM_VERSION
export LLVM_LINK_NAME=/usr/bin/llvm-link-$LLVM_VERSION
export LLVM_AR_NAME=/usr/bin/llvm-ar-$LLVM_VERSION
export LLVM_COMPILER=/usr/bin/clang-$LLVM_VERSION
# export LLVM_CC_NAME=/usr/bin/clang-$LLVM_VERSION
# export LLVM_CXX_NAME=/usr/bin/clang++-$LLVM_VERSION

export FORCE_UNSAFE_CONFIGURE=1

ROOTDIR=$(pwd)

# collect all binaries here
mkdir -p $ROOTDIR/bin

echo "Installing klee-uclibc"
    git clone https://github.com/klee/klee-uclibc.git || true
    pushd klee-uclibc
    ./configure --make-llvm-lib --with-llvm-config=/usr/bin/llvm-config-$LLVM_VERSION
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

echo "Building LLVM simplification passes"
    pushd LLVM_Passes
    mkdir -p build
    cd build
    cmake -DLLVM_DIR=/usr/lib/llvm-10/lib/cmake/llvm ..
    make -j $(nproc)
    popd
