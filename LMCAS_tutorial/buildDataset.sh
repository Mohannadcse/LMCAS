#!/bin/bash

mkdir bitcode_files

echo "Preparing Dataset-1"
wget https://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.gz 
mkdir Dataset-1 
tar -xf coreutils-8.32.tar.gz -C Dataset-1
rm coreutils-8.32.tar.gz
find Dataset-1_src -name \*.c -exec cp {} Dataset-1/coreutils-8.32/src \; 
cd Dataset-1/coreutils-8.32/
mkdir obj-llvm
cd obj-llvm
CC=wllvm ../configure \
      --disable-nls \
      CFLAGS="-g -O0 -Xclang  -D__NO_STRING_INLINES  -D_FORTIFY_SOURCE=0 -U__OPTIMIZE__"
make
cd src
find . -executable -type f | xargs -I '{}' extract-bc '{}'


echo "Preparing Dataset-2"

cd /Datasets
mkdir Dataset-3 && cd Dataset-3
echo "Preparing Dataset-3"
#libcap
git clone https://github.com/the-tcpdump-group/libpcap.git libpcap
cd libpcap
CC=wllvm ./configure --disable-largefile --disable-shared --without-gcc --without-libnl --disable-dbus --without-dag --without-snf CFLAGS="-g -O0"
sed -i "s/-fpic//" Makefile
CC=wllvm make -j4
cd ..

#tcpdump
git clone https://github.com/the-tcpdump-group/tcpdump.git tcpdump
cd tcpdump
cp /Datasets/Dataset-3_src/tcpdump.c .
ln -s ../libpcap libpcap
sed -i "s/HASHNAMESIZE 4096/HASHNAMESIZE 8/" addrtoname.c
sed -i "s/HASHNAMESIZE 4096/HASHNAMESIZE 8/" print-atalk.c
CC=wllvm ./configure --without-sandbox-capsicum --without-crypto --without-cap-ng --without-smi  CFLAGS="-g -O0"
CC=wllvm make -j4
extract-bc tcpdump
cd ..

#Binutils
git clone https://sourceware.org/git/binutils-gdb.git binutils
cd binutils
cp /Datasets/Dataset-3_src/objdump.c /Datasets/Dataset-3_src/readelf.c binutils
git checkout -f 427234c78bddbea7c94fa1a35e74b7dfeabeeb43
find . -name configure -exec sed -i "s/ -Werror//" '{}' \;
find . -name "Makefile*" -exec sed -i '/^SUBDIRS/s/ doc po//' '{}' \;
mkdir -p obj-llvm/bc
cd obj-llvm
CC=wllvm ../configure --disable-nls --disable-largefile --disable-gdb --disable-sim --disable-readline --disable-libdecnumber --disable-libquadmath --disable-libstdcxx --disable-ld --disable-gprof --disable-gas --disable-intl --disable-etc CFLAGS="-g -O0"
sed -i 's/ -static-libstdc++ -static-libgcc//' Makefile
CC=wllvm make -j4
find binutils -executable -type f -exec file '{}' \; | grep ELF | cut -d: -f1 | xargs -n 1 extract-bc
find binutils -name "*.bc" -not -name "*.o.bc" -not -name ".conf*" -not -name "bfdtest*" -exec cp '{}' "bc/" \;
cd ..

for f in `cat /Datasets/Dataset-1_src/Dataset-1-list.txt`
do
	cp /Datasets/Dataset-1/coreutils-8.32/obj-llvm/src/"$f".bc bitcode_files/
done

cp /Datasets/Dataset-3/tcpdump/tcpdump.bc bitcode_files/
cp /Datasets/Dataset-3/binutils/obj-llvm/bc/readelf.bc /Datasets/Dataset-3/binutils/obj-llvm/bc/objdump.bc bitcode_files/

