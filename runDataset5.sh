#!/bin/bash

# ./buildDataset.sh
# ./build-lmcas.sh

./runAnalysis_automated.sh --file:bitcode_files/knockd.bc --args:"-i eth0"
./runAnalysis_automated.sh --file:bitcode_files/curl.bc --args:"--compress --http1.1 --IPV4 --ssl"
