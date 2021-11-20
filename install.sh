#!/bin/bash
set -ex

LLVM_VERSION=12

echo "Installing dependencies."
    sudo apt-get update
    sudo apt-get install -y \
        wget libprotobuf-dev python-protobuf protobuf-compiler  \
        python3-pip  \
        libz3-dev  \
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
        libncursesw5-dev \
        lsb-release wget software-properties-common
echo "Downloading LLVM"    
    wget https://apt.llvm.org/llvm.sh -O /tmp/llvm.sh
    chmod +x /tmp/llvm.sh
    sudo /tmp/llvm.sh ${LLVM_VERSION}

