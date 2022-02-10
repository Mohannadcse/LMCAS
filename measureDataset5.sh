#!/bin/bash

# ./buildDataset.sh
# ./build-lmcas.sh

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/wget.bc --args:"--config benchmarks/binaries/wgetrc" > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/knockd.bc --args:"-i eth0" > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/curl.bc --args:"--compress --http1.1 --IPV4 --ssl" > log 

cat log |& grep -E "wall|resident"
