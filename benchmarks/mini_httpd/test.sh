#!/bin/bash

echo "\t\tTesting Mini"

cd ../../benchmarks/binaries

./mini_httpd_orig -C ./mini_httpd.conf
wget 127.0.0.1:8087/

sed -i 's/8087/8088/g' ./mini_httpd.conf
./mini_httpd_cu
wget 127.0.0.1:8088/

cmp -s ./index.html index.html.1; \
RETVAL=$$?; \
if [ $$RETVAL -eq 0 ]; then \
        echo "\tmini_httpd test baseline compare? Passed!"; \
else \
        echo "\tmini_httpd test baseline compare? Failed!"; \
fi

cd -
