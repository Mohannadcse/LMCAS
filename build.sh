#!/bin/sh

LLVM_VERSION=10
export CC=clang-$LLVM_VERSION
export CXX=clang++-$LLVM_VERSION
export LLVM_CC_NAME clang-$LLVM_VERSION
export LLVM_CXX_NAME clang++-$LLVM_VERSION
export LLVM_LINK_NAME llvm-link-$LLVM_VERSION
export LLVM_AR_NAME llvm-ar-$LLVM_VERSION
export LLVM_COMPILER clang-$LLVM_VERSION
export FORCE_UNSAFE_CONFIGURE=1

echo "Installing dependencies." && \
    sudo apt-get update && \
    sudo apt-get install -y \
        wget libprotobuf-dev python-protobuf protobuf-compiler  \
        python3-pip  \
        libz3-dev  \
        llvm-$LLVM_VERSION-dev  \
        clang-$LLVM_VERSION  \
        git  \
        cmake  \
        zlib1g-dev  \
        build-essential \
        gperf  libgoogle-perftools-dev  \
        libboost-dev  \
        flex  \
        bison  \
        nano  \
        iputils-ping \
        libibverbs-dev

echo "Installing WLLVM"  \
    pip3 install -U lit tabulate wllvm

ROOTDIR=$(pwd)

# collect all binaries here
mkdir $ROOTDIR/bin

echo "Installing klee-uclibc" && \
    git clone https://github.com/klee/klee-uclibc.git && \
    pushd klee-uclibc && \
    ./configure --make-llvm-lib --with-llvm-config=/usr/bin/llvm-config-$LLVM_VERSION && \
    make -j $(nproc) && \
    popd

echo "Building KLEE" && \ 
    pushd partial-interpretation && \
    mkdir -p build && \
    cd build && \
    cmake   \
        -DCMAKE_INSTALL_PREFIX:PATH=$ROOTDIR/bin
        -DENABLE_SOLVER_Z3=ON  \ 
        -DENABLE_POSIX_RUNTIME=ON  \ 
        -DENABLE_KLEE_UCLIBC=ON   \
        -DKLEE_UCLIBC_PATH=../../klee-uclibc \
        ..  && \
        make -j $(nproc) && \
        make install && \
    popd

echo "Building LLVM simplification passes" && \
    pushd LLVM_Passes && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j $(nproc) && \
    popd
