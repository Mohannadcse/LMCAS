#!/bin/bash
set -ex

LLVM_VERSION=12

 echo "Installing dependencies.1"
     sudo apt-get update
     sudo apt-get install -y \
         wget libprotobuf-dev python-protobuf protobuf-compiler  \
         python3-pip  \
         libz3-dev  \
         git  \
         zlib1g-dev  \
         gperf  libgoogle-perftools-dev  \
         libboost-dev  \
         flex  \
         bison  \
         nano  \
         iputils-ping \
         libibverbs-dev \
         libncursesw5  \
         libncursesw5-dev 

echo "Installing dependencies.2"

# Basics
sudo apt-get install -y build-essential gpg wget lsb-release software-properties-common

# CMake
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null

echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
sudo apt-get update
# CMake and Ninja
sudo apt-get install -y cmake ninja-build

# Update GCC compiler for an up-to-date libstdc++ implementation
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install -y gcc-11 g++-11


# echo "Downloading LLVM"    
#     wget https://apt.llvm.org/llvm.sh -O /tmp/llvm.sh
#     chmod +x /tmp/llvm.sh
#     sudo /tmp/llvm.sh ${LLVM_VERSION}


