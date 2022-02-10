#!/bin/bash

# ./buildDataset.sh
# ./build-lmcas.sh

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/basename.bc --args:suffix=.txt > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/baseenc.bc --args:base64 > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/comm.bc --args:-12 > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/date.bc --args:-R > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/du.bc --args:-h > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/echo.bc  --args:-E > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/fmt.bc --args:-c > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/head.bc --args:-w30 > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/fold.bc --args:-n3 > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/id.bc --args:-G > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/kill.bc  --args:-9 > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/reapath.bc --args:-P > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/sort.bc --args:-u > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/uniq.bc --args:-d > log 

cat log |& grep -E "wall|resident"

/usr/bin/time -v ./runAnalysis_automated.sh --file:bitcode_files/wc.bc --args:-l > log 

cat log |& grep -E "wall|resident"
