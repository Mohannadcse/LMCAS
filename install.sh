#!/bin/bash
set -ex

LLVM_VERSION=10

echo "Installing dependencies."
    sudo apt-get update
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
        libibverbs-dev \
        libncursesw5  \
        libncursesw5-dev
