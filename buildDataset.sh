#!/bin/bash

export LLVM_VERSION=12
export CC=/usr/local/bin/clang
export CXX=/usr/local/bin/clang++
export LLVM_CONFIG_BINARY=/usr/local/bin/llvm-config
export LLVM_LINK_NAME=llvm-link
export LLVM_AR_NAME=llvm-ar
export LLVM_COMPILER=clang

gsanity-check

export PATH=$PATH:$(go env GOPATH)/bin

ROOTDIR=$(pwd)

mkdir -p bitcode_files

echo "Preparing Dataset-1"
wget https://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.gz
tar -xf coreutils-8.32.tar.gz -C Dataset-1
rm -rf coreutils-8.32.tar.gz

# find Dataset-1 -name \*.c -exec cp {} Dataset-1/coreutils-8.32/src \; 
cd Dataset-1/coreutils-8.32/
mkdir -p obj-llvm
cd obj-llvm
CC=gclang ../configure \
      --disable-nls \
      CFLAGS="-g -O0 -Xclang  -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
make -j $(nproc)
cd src
find . -executable -type f | xargs -I '{}' get-bc '{}'

cd $ROOTDIR

echo "Preparing Dataset-2"


mkdir -p Dataset-3 && cd Dataset-3
echo "Preparing Dataset-3"
#libcap
git clone --depth 1 https://github.com/the-tcpdump-group/libpcap.git libpcap
cd libpcap
CC=gclang ./configure --disable-largefile --disable-shared --without-gcc --without-libnl --disable-dbus --without-dag --without-snf CFLAGS="-g -O0"
sed -i "s/-fpic//" Makefile
CC=gclang make -j $(nproc)
cd ..

#tcpdump
git clone --depth 1 https://github.com/the-tcpdump-group/tcpdump.git tcpdump
cd tcpdump
cp $ROOTDIR/Dataset-3/tcpdump.c .
ln -s ../libpcap libpcap
sed -i "s/HASHNAMESIZE 4096/HASHNAMESIZE 8/" addrtoname.c
sed -i "s/HASHNAMESIZE 4096/HASHNAMESIZE 8/" print-atalk.c
CC=gclang ./configure --without-sandbox-capsicum --without-crypto --without-cap-ng --without-smi  CFLAGS="-g -O0"
CC=gclang make -j4
get-bc tcpdump
cd ..

#Binutils
git clone --depth 1 https://sourceware.org/git/binutils-gdb.git binutils
cd binutils
cp $ROOTDIR/Dataset-3/objdump.c $ROOTDIR/Dataset-3/readelf.c binutils
git checkout -f 427234c78bddbea7c94fa1a35e74b7dfeabeeb43
find . -name configure -exec sed -i "s/ -Werror//" '{}' \;
find . -name "Makefile*" -exec sed -i '/^SUBDIRS/s/ doc po//' '{}' \;
mkdir -p obj-llvm/bc
cd obj-llvm
CC=gclang ../configure --disable-nls --disable-largefile --disable-gdb --disable-sim --disable-readline --disable-libdecnumber --disable-libquadmath --disable-libstdcxx --disable-ld --disable-gprof --disable-gas --disable-intl --disable-etc CFLAGS="-g -O0"
sed -i 's/ -static-libstdc++ -static-libgcc//' Makefile
CC=gclang make -j4
find binutils -executable -type f -exec file '{}' \; | grep ELF | cut -d: -f1 | xargs -n 1 get-bc
find binutils -name "*.bc" -not -name "*.o.bc" -not -name ".conf*" -not -name "bfdtest*" -exec cp '{}' "bc/" \;
cd ..

#dnsproxy
git clone --depth 1 git@github.com:awaw/dnsproxy.git
cd dnsproxy/
bootstrap
CC=gclang ./configure CFLAGS="-g -O0"
make -j4
get-bc dnsproxy
cd ..

cd $ROOTDIR

for f in `cat Dataset-1/Dataset-1-list.txt`
do
	cp -f Dataset-1/coreutils-8.32/obj-llvm/src/"$f".bc bitcode_files/
done

cp Dataset-3/tcpdump/tcpdump.bc bitcode_files/
cp Dataset-3/binutils/obj-llvm/bc/readelf.bc Dataset-3/binutils/obj-llvm/bc/objdump.bc bitcode_files/

# wget and curl
echo "Preparing Dataset-5"
mkdir -p Dataset-5

# wget
wget https://ftp.gnu.org/gnu/wget/wget-1.17.1.tar.gz
tar -xf wget-1.17.1.tar.gz -C Dataset-5
rm wget-1.17.1.tar.gz

cd Dataset-5/wget-1.17.1/
mkdir -p obj-llvm
cd obj-llvm
CC=gclang ../configure \
      --with-gnutls \
      CFLAGS="-g -O0 -Xclang  -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
make -j $(nproc)
cd src
find . -executable -type f | xargs -I '{}' get-bc '{}'

cd $ROOTDIR

cp Dataset-5/wget-1.17.1/obj-llvm/src/*.bc bitcode_files/

# curl
wget https://github.com/curl/curl/archive/refs/tags/curl-7_47_0.tar.gz
mkdir -p Dataset-5/curl-7_47_0/ && tar -xf curl-7_47_0.tar.gz -C Dataset-5/curl-7_47_0/ --strip-components=1
rm curl-7_47_0.tar.gz

cd Dataset-5/curl-7_47_0/
./buildconf
# mkdir -p obj-llvm
# cd obj-llvm
CC=gclang ./configure \
      --enable-warnings --enable-werror \
      --with-openssl \
      CFLAGS="-g -O0 -Xclang  -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
make -j $(nproc)
cd src
find . -executable -type f | xargs -I '{}' get-bc '{}'

cd $ROOTDIR

cp Dataset-5/curl-7_47_0/src/*.bc bitcode_files/
