
# Pull base image.
FROM buildpack-deps:bionic

RUN echo "Build type set to: Release" && \
     # Install deps.
    apt-get update && \
    apt-get install -yqq software-properties-common && \
    apt-get update && \
    apt-get install -y wget libprotobuf-dev python-protobuf protobuf-compiler && \
    apt-get install -y python-pip && \
    apt-get install -y python3-pip && \
    #apt-get install -y z3 && \
    apt-get install -y libz3-dev && \
    apt-get install -y llvm-6.0-dev && \
    apt-get install llvm-6.0-tool && \
    apt-get install -y clang-6.0 && \
    apt-get install -y git && \
    apt-get install -y cmake && \
    apt-get install -y zlib1g-dev && \
    apt-get install -y build-essential &&\
    apt-get install -y gperf  libgoogle-perftools-dev && \
    apt-get install -yqq libboost-dev && \
    apt-get install -y flex && \
    apt-get install -y bison && \
    apt-get install nano && \
    apt-get install -y libibverbs-dev


RUN echo "Install WLLVM" && \
    pip3 install -U lit tabulate wllvm


RUN echo "Download google tests" && \
    curl -OL https://github.com/google/googletest/archive/release-1.7.0.zip && \
    unzip release-1.7.0.zip && \
    rm release-1.7.0.zip

RUN echo "Install klee-uclibc" && \
    git clone https://github.com/klee/klee-uclibc.git && \
    cd klee-uclibc && \
    ./configure --make-llvm-lib --with-llvm-config=/usr/bin/llvm-config-6.0 && \
    make -j2


ADD debloat KLEE
ADD LLVM_Passes LLVM_Passes_src

WORKDIR build/KLEE

RUN echo "Buildg KLEE" && \ 
    cmake   \
        -DENABLE_SOLVER_Z3=ON  \ 
        -DENABLE_POSIX_RUNTIME=ON  \ 
        -DENABLE_KLEE_UCLIBC=ON   \
        -DKLEE_UCLIBC_PATH=/klee-uclibc \ 
        -DENABLE_UNIT_TESTS=ON \
        -DGTEST_SRC_DIR=../../googletest-release-1.7.0  \
        -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config-6.0 \  
        -DLLVMCC=/usr/bin/clang-6.0  \
        -DLLVMCXX=/usr/bin/clang++-6.0   \
        /KLEE  && \
    make && \
    make install 

WORKDIR ../LLVM_Passes

RUN echo "Build LLVM simplification passes" && \
    cmake -DLLVM_DIR=/usr/lib/llvm-6.0/lib/cmake/llvm \
    /LLVM_Passes_src && \
    make

WORKDIR /
WORKDIR Datasets

ADD artifacts_bitcode artifacts_bitcode
ADD Dataset-1 Dataset-1_src
ADD Dataset-3 Dataset-3_src
COPY buildDataset.sh buildDataset.sh
COPY runAnalysis.sh  runAnalysis.sh

ENV LLVM_CC_NAME clang-6.0
ENV LLVM_CXX_NAME clang++-6.0
ENV LLVM_LINK_NAME llvm-link-6.0
ENV LLVM_AR_NAME llvm-ar-6.0
ENV LLVM_COMPILER clang
ENV FORCE_UNSAFE_CONFIGURE=1

