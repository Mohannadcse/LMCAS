#!/bin/bash

# ./buildDataset.sh
# ./build-lmcas.sh

./runAnalysis_automated.sh --file:bitcode_files/objdump.bc --args:"-D --syms -s -w benchmark/binaries/test"
./runAnalysis_automated.sh --file:bitcode_files/readelf.bc --args:"-a benchmark/binaries/test"
