
# Pull base image.
FROM buildpack-deps:bionic

RUN echo "Build type set to: Release" && \
     # Install deps.
    apt-get update && \
    apt-get install -yqq software-properties-common && \
    apt-get update && \
    apt-get install -y wget libprotobuf-dev python-protobuf protobuf-compiler && \
    apt-get install -y python-pip && \
    apt-get install -y python3-dev && \
    apt-get install -y python3-pip && \
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
    apt-get install -y iputils-ping && \
    apt-get install -y libibverbs-dev  

RUN echo "update pip3"  && \
    pip3 install -U pip 

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

RUN echo "Install ROPGadget" && \
    pip3 install capstone && \
    pip3 install numpy && \
    pip3 install matplotlib && \
    pip3 install pandas && \
    pip3 install ropgadget 
ADD build        build
WORKDIR /usr/local/bin
RUN ln -s /build/KLEE/bin/klee klee

WORKDIR /
WORKDIR Datasets

ADD bitcode_files bitcode_files
ADD source_code_files source_code_files
COPY ropAnalysis.sh  ropAnalysis.sh
COPY statistics.sh stats.sh 
COPY runDemo.sh  runDemo.sh
COPY testScript.sh testRunDemo.sh
COPY create_histograms.py create_histograms.py


ENV LLVM_CC_NAME clang-6.0
ENV LLVM_CXX_NAME clang++-6.0
ENV LLVM_LINK_NAME llvm-link-6.0
ENV LLVM_AR_NAME llvm-ar-6.0
ENV LLVM_COMPILER clang
ENV FORCE_UNSAFE_CONFIGURE=1

