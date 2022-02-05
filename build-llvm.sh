#!/bin/bash
set -ex

export LLVM_VERSION=12

export FORCE_UNSAFE_CONFIGURE=1

ROOTDIR=$(pwd)

# Build and install LLVM
git clone -b llvmorg-12.0.1 --depth 1 https://github.com/llvm/llvm-project.git 
cd llvm-project/
mkdir build
cd build/
cmake -G "Ninja" -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;lld;compiler-rt;debuginfo-tests' -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_ENABLE_DUMP=ON -DLLVM_BUILD_EXAMPLES=Off -DLLVM_INCLUDE_EXAMPLES=Off -DLLVM_BUILD_TESTS=Off -DLLVM_INCLUDE_TESTS=Off -DPYTHON_EXECUTABLE="$(which python3)" ../llvm
ninja
ninja install
