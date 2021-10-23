
# Pull base image.
sudo -ex

LLVM_VERSION=10
export CC=clang-$LLVM_VERSION
export CXX=clang++-$LLVM_VERSION
export LLVM_CC_NAME clang-$LLVM_VERSION
export LLVM_CXX_NAME clang++-$LLVM_VERSION
export LLVM_LINK_NAME llvm-link-$LLVM_VERSION
export LLVM_AR_NAME llvm-ar-$LLVM_VERSION
export LLVM_COMPILER clang-$LLVM_VERSION
export FORCE_UNSAFE_CONFIGURE=1

# Install deps.
echo "Build type set to: Release" && \
    sudo apt-get update && \
    sudo apt-get install -yqq software-properties-common && \
    sudo apt-get update && \
    sudo apt-get install -y wget libprotobuf-dev python-protobuf protobuf-compiler && \
    sudo apt-get install -y python3-pip && \
    sudo apt-get install -y libz3-dev && \
    sudo apt-get install -y llvm-$LLVM_VERSION-dev && \
    sudo apt-get install -y clang-$LLVM_VERSION && \
    sudo apt-get install -y git && \
    sudo apt-get install -y cmake && \
    sudo apt-get install -y zlib1g-dev && \
    sudo apt-get install -y build-essential &&\
    sudo apt-get install -y gperf  libgoogle-perftools-dev && \
    sudo apt-get install -yqq libboost-dev && \
    sudo apt-get install -y flex && \
    sudo apt-get install -y bison && \
    sudo apt-get install nano && \
    sudo apt-get install iputils-ping && \
    sudo apt-get install -y libibverbs-dev

echo "Install WLLVM" && \
    pip3 install -U lit tabulate wllvm

ROOTDIR=$(pwd)

# collect all binaries here
mkdir $ROOTDIR/bin

echo "Install klee-uclibc" && \
    git clone https://github.com/klee/klee-uclibc.git && \
    pushd klee-uclibc && \
    ./configure --make-llvm-lib --with-llvm-config=/usr/bin/llvm-config-$LLVM_VERSION && \
    make -j $(nproc) && \
    popd

echo "Buildg KLEE" && \ 
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

echo "Build LLVM simplification passes" && \
    pushd LLVM_Passes && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j $(nproc) && \
    popd
