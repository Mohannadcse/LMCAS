#!/bin/bash

set -x

export LLVM_COMPILER=clang
export LLVM_COMPILER_PATH=/usr/local/bin

# wllvm-sanity-checker

ROOTDIR=$(pwd)

mkdir bitcode_files

echo "Preparing Dataset-1"
mkdir -p  Dataset-1

wget https://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.gz
tar -xf coreutils-8.32.tar.gz -C Dataset-1
rm coreutils-8.32.tar.gz

find annotated_Dataset-1 -name \*.c -exec cp {} Dataset-1/coreutils-8.32/src \;
cd Dataset-1/coreutils-8.32/
mkdir obj-llvm
cd obj-llvm
FORCE_UNSAFE_CONFIGURE=1 CC=wllvm ../configure \
      --disable-nls \
      CFLAGS="-g -O0 -Xclang  -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
make -j $(nproc)
cd src
find . -executable -type f | xargs -I '{}' extract-bc '{}'
cd $ROOTDIR

for f in `cat annotated_Dataset-1/Dataset-1-list.txt`
do
        cp Dataset-1/coreutils-8.32/obj-llvm/src/"$f".bc bitcode_files/
done

echo "Preparing Dataset-2"
mkdir -p Dataset-2
echo "TODO"


echo "Preparing Dataset-3"
mkdir -p Dataset-3

#libcap
cd Dataset-3
git clone https://github.com/the-tcpdump-group/libpcap.git libpcap
cd libpcap
CC=wllvm ./configure --disable-largefile --disable-shared --without-gcc --without-libnl --disable-dbus --without-dag --without-snf CFLAGS="-g -O0"
sed -i "s/-fpic//" Makefile
CC=wllvm make -j $(nproc)
cd $ROOTDIR

#tcpdump
cd Dataset-3
git clone https://github.com/the-tcpdump-group/tcpdump.git tcpdump
cd tcpdump
git fetch --all --tags --prune
git checkout -f tags/tcpdump-4.9.0-bp-1940-g6b1a867b
cp $ROOTDIR/Dataset-3/tcpdump.c .
ln -s ../libpcap libpcap
sed -i "s/HASHNAMESIZE 4096/HASHNAMESIZE 8/" addrtoname.c
sed -i "s/HASHNAMESIZE 4096/HASHNAMESIZE 8/" print-atalk.c
CC=wllvm ./configure --without-sandbox-capsicum --without-crypto --without-cap-ng --without-smi  CFLAGS="-g -O0"
CC=wllvm make -j $(nproc)
extract-bc tcpdump
cd $ROOTDIR

cp Dataset-3/tcpdump/tcpdump.bc bitcode_files/

#Binutils

cd Dataset-3
git clone https://sourceware.org/git/binutils-gdb.git binutils
cd binutils
git checkout -f 427234c78bddbea7c94fa1a35e74b7dfeabeeb43
cp $ROOTDIR/Dataset-3/objdump.c $ROOTDIR/Dataset-3/readelf.c binutils
find . -name configure -exec sed -i "s/ -Werror//" '{}' \;
find . -name "Makefile*" -exec sed -i '/^SUBDIRS/s/ doc po//' '{}' \;
mkdir -p obj-llvm/bc
cd obj-llvm
CC=wllvm ../configure --disable-nls --disable-largefile --disable-gdb --disable-sim --disable-readline --disable-libdecnumber --disable-libquadmath --disable-libstdcxx --disable-ld --disable-gprof --disable-gas --disable-intl --disable-etc CFLAGS="-g -O0"
sed -i 's/ -static-libstdc++ -static-libgcc//' Makefile
CC=wllvm make -j $(nproc)
find binutils -executable -type f -exec file '{}' \; | grep ELF | cut -d: -f1 | xargs -n 1 extract-bc
find binutils -name "*.bc" -not -name "*.o.bc" -not -name ".conf*" -not -name "bfdtest*" -exec cp '{}' "bc/" \;
cd $ROOTDIR

cp Dataset-3/binutils/obj-llvm/bc/readelf.bc Dataset-3/binutils/obj-llvm/bc/objdump.bc bitcode_files/

#dnsproxy
cd Dataset-3
git clone git@github.com:awaw/dnsproxy.git
cd dnsproxy/
./bootstrap
CC=wllvm ./configure CFLAGS="-g -O0"
make -j $(nproc)
extract-bc dnsproxy
cd $ROOTDIR

cp Dataset-3/dnsproxy/*.bc bitcode_files/


echo "Preparing Dataset-4"
mkdir -p Dataset-4
echo "TODO"

echo "Preparing Dataset-5"
mkdir -p Dataset-5

# wget
cd Dataset-5
wget https://ftp.gnu.org/gnu/wget/wget-1.17.1.tar.gz
tar -xf wget-1.17.1.tar.gz -C Dataset-5
rm wget-1.17.1.tar.gz

cd Dataset-5/wget-1.17.1/
mkdir -p obj-llvm
cd obj-llvm
CC=wllvm ../configure \
      --with-gnutls \
      CFLAGS="-g -O0 -Xclang  -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
make -j $(nproc)
cd src
find . -executable -type f | xargs -I '{}' extract-bc '{}'

cd $ROOTDIR


cd Dataset-5

# the file htpasswd.c doesn't build correctly, but mini-httpd builds correctly

git clone https://github.com/peter-leonov/mini_httpd.git
cd mini_httpd/
git checkout tags/v1.19

sed -i 's/CC =		/CC? = /g' ./Makefile
sed -i 's/-O/ -Xclang -disable-O0-optnone/g' ./Makefile
sed -i 's/LDFLAGS/#LDFLAGS/g' ./Makefile

CC=wllvm make -j $(nproc)
extract-bc ./mini_httpd
cp mini_httpd/mini_httpd.bc $ROOTDIR/bitcode_files/

cd $ROOTDIR

cp Dataset-5/wget-1.17.1/obj-llvm/src/*.bc bitcode_files/

# curl
wget https://github.com/shoaibCS/TRIMMER-applications/raw/master/trimmer/curl/curl-7.47.0.tar.gz
mkdir -p Dataset-5/curl-7.47.0/ && tar -xf curl-7.47.0.tar.gz -C Dataset-5/curl-7.47.0/ --strip-components=1
rm curl-7.47.0.tar.gz

cd Dataset-5/curl-7.47.0/
CC=wllvm CFLAGS="-g -O0 -Xclang -disable-O0-optnone -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__" ./configure --with-openssl
sed -i 's/CFLAGS = -Xclang -disable-O0-optnone -Qunused-arguments -Os/CFLAGS = -Xclang -disable-O0-optnone/g' src/Makefile
make -j $(nproc)
sudo make install
cp /usr/local/bin/curl .
extract-bc ./curl

cd $ROOTDIR

cp Dataset-5/curl-7.47.0/curl.bc bitcode_files/

# knockd
wget https://github.com/shoaibCS/TRIMMER-applications/raw/master/trimmer/knockd/knockd-0.5.tar.gz

mkdir -p Dataset-5/knockd-0.5/ && tar -xf knockd-0.5.tar.gz -C Dataset-5/knockd-0.5/ --strip-components=1
rm knockd-0.5.tar.gz

cd Dataset-5/knockd-0.5/
CC=wllvm ./configure \
      CFLAGS="-g -O0 -Xclang -disable-O0-optnone -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
sed -i 's/-g -Wall -pedantic -fno-exceptions/-Wall -pedantic -fno-exceptions -Xclang -disable-O0-optnone/g' ./Makefile
CC=wllvm make -j $(nproc)
find . -executable -type f | xargs -I '{}' extract-bc '{}'

cd $ROOTDIR

# diffutils
wget https://ftp.gnu.org/gnu/diffutils/diffutils-2.8.tar.gz
mkdir -p Dataset-5/diffutils-2.8/ && tar -xf diffutils-2.8.tar.gz -C Dataset-5/diffutils-2.8/ --strip-components=1
rm diffutils-2.8.tar.gz

cd Dataset-5/diffutils-2.8/ 

CC=wllvm CFLAGS="-g -O0 -Xclang -disable-O0-optnone -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__" ./configure 
make -j $(nproc)
extract-bc src/diff

cd $ROOTDIR

cp Dataset-5/knockd-0.5/knockd.bc bitcode_files/


# memcached
wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz

mkdir -p Dataset-5/libevent-2.0.21/ && tar -xf libevent-2.0.21-stable.tar.gz -C Dataset-5/libevent-2.0.21/ --strip-components=1
rm libevent-2.0.21-stable.tar.gz

cd Dataset-5/libevent-2.0.21/
LIBEVENT_INSTALL=$(pwd)/libevent
./buildconf
mkdir -p $LIBEVENT_INSTALL
CC=wllvm ./configure --prefix=$LIBEVENT_INSTALL --disable-openssl
CC=wllvm make -j $(nproc)
CC=wllvm make install

# Generate libevent.bca
extract-bc $LIBEVENT_INSTALL/lib/libevent.a

cd $ROOTDIR

wget https://github.com/shamedgh/temporal-specialization/blob/master/application-sourcecodes/memcached.tar.gz?raw=true

mkdir -p Dataset-5/memcached-1.4.25/ && tar -xf memcached.tar.gz?raw=true -C Dataset-5/memcached-1.4.25/ --strip-components=1
rm memcached.tar.gz?raw=true

cd Dataset-5/memcached-1.4.25/

MEMCACHED_INSTALL=$(pwd)/memcached
mkdir -p $MEMCACHED_INSTALL

./autogen.sh

CC=clang ./configure --prefix=${MEMCACHED_INSTALL} --with-libevent=${LIBEVENT_INSTALL}
CC=clang make -j $(nproc) #TODO: This step does not work.
extract-bc $MEMCACHED_INSTALL/lib/memcached.bc

cd $ROOTDIR

cp Dataset-5/memcached-1.4.25/memcached.bc bitcode_files/


# bind9
wget https://github.com/shamedgh/temporal-specialization/blob/master/application-sourcecodes/bind9.tar.gz?raw=true

mkdir -p Dataset-5/bind9/ && tar -xf bind9.tar.gz?raw=true -C Dataset-5/bind9/ --strip-components=1
rm bind9.tar.gz?raw=true

cd Dataset-5/bind9/
CC=wllvm ./configure --without-python --disable-linux-caps
sed -i 's/CFLAGS = -g -O2 -Wall -Werror -pedantic -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls/CFLAGS = -Xclang -disable-O0-optnone -O0/g' ./Makefile
CC=wllvm make -j $(nproc)
extract-bc bin/named/named

cd $ROOTDIR

cp Dataset-5/bind9/bin/named/named.bc bitcode_files/

cd $ROOTDIR

# redis
wget https://github.com/shamedgh/temporal-specialization/blob/master/application-sourcecodes/redis-5.0.7.tar.gz?raw=true

mkdir -p Dataset-5/redis-5.0.7/ && tar -xf redis-5.0.7.tar.gz?raw=true -C Dataset-5/redis-5.0.7/ --strip-components=1
rm redis-5.0.7.tar.gz?raw=true

cd Dataset-5/redis-5.0.7/
sed -i 's/CFLAGS = -g -O2 -Wall -Werror -pedantic -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls/CFLAGS = -Xclang -disable-O0-optnone -O0/g' ./Makefile
CC=wllvm make -j $(nproc)
extract-bc bin/redis

cd $ROOTDIR

cp Dataset-5/redis-5.0.7/bin/redis/redis.bc bitcode_files/

cd $ROOTDIR
