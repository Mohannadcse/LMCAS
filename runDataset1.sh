#!/bin/bash

# ./buildDataset.sh
# ./build-lmcas.sh

./runAnalysis_automated.sh --file:bitcode_files/basename.bc --args:suffix=.txt

./runAnalysis_automated.sh --file:bitcode_files/baseenc.bc --args:base64

./runAnalysis_automated.sh --file:bitcode_files/comm.bc --args:-12

./runAnalysis_automated.sh --file:bitcode_files/date.bc --args:-R

./runAnalysis_automated.sh --file:bitcode_files/du.bc --args:-h

./runAnalysis_automated.sh --file:bitcode_files/echo.bc --args:-E

./runAnalysis_automated.sh --file:bitcode_files/fmt.bc --args:-c

./runAnalysis_automated.sh --file:bitcode_files/head.bc --args:-w30

./runAnalysis_automated.sh --file:bitcode_files/fold.bc --args:-n3

./runAnalysis_automated.sh --file:bitcode_files/id.bc --args:-G

./runAnalysis_automated.sh --file:bitcode_files/kill.bc --args:-9

./runAnalysis_automated.sh --file:bitcode_files/reapath.bc --args:-P

./runAnalysis_automated.sh --file:bitcode_files/sort.bc --args:-u

./runAnalysis_automated.sh --file:bitcode_files/uniq.bc --args:-d

./runAnalysis_automated.sh --file:bitcode_files/wc.bc --args:-l
