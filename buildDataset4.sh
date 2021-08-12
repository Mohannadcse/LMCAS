#**YICES**
git clone https://github.com/SRI-CSL/yices2
cd yices2
autoconf
CC=wllvm ./configure   CFLAGS="-Xclang -disable-O0-optnone -g -O0"
make
echo "it generated the executable under /Datasets/yices2/build/x86_64-pc-linux-gnu-release/bin  in LMCAS docker"
cd build/x86_64-pc-linux-gnu-release/bin
extract-bc yices

#
**CURL**
git clone https://github.com/curl/curl curl_source
cd curl_source
autoreconf -fi
–compress –http2.0 –ipv4 –ssl –url
./configure CC=wllvm CFLAGS=" -Xclang -disable-O0-optnone" --with-openssl
dd
git clone https://github.com/curl/curl
autoreconf -fi
CC=wllvm CFLAGS=" -Xclang -disable-O0-optnone" ./configure

