#!/bin/bash

set -x

# for avoiding memory issue while running phasar
ulimit -s 16777216

LLVM_VERSION=12

RED='\033[0;31m'
NC='\e[0m' # No Color

#i noticed this is required while debloating tcpdump
#export LLVM_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-$LLVM_VERSION

ROOTDIR=$(pwd)

# collect all binaries here
export BIN=$ROOTDIR/bin

function usage()
{
    echo -e "${RED} Syntax: ./runAnalysis.sh --file=path/to/bitcode.bc${NC} --args=partial inputs"
    echo -e "${RED} if there are spaces in the partial inputs, then please use${NC} double qutation"
    echo -e "${RED} Examples: ${NC}"
    echo -e "${RED} ./runAnalysis.sh --file:wc.bc --args:-l${NC}"
    echo -e "${RED} ./runAnalysis.sh --file:tcpdump.bc --args:\"-i lo\" ${NC}"
    exit 1
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F: '{print $1}'`
    VALUE=`echo $1 | awk -F: '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --file)
            F=$VALUE
            ;;
        --args)
            args=$VALUE
            ;;
        *)
            echo -e "${RED} ERROR: unknown parameter \"$PARAM\"${NC}"
            usage
            ;;
    esac
    shift
done

if [ "$F" == "" ] || [ "$args" == "" ]; then
    usage
fi

echo -e "${RED} Bitcode File is $F"${NC};
echo -e "${RED} Args is $args"${NC};

appWithExt=$(basename $F)
ext=${appWithExt##*.}
app=$(basename $F .$ext)
appFullPath=$(realpath $F)

echo -e "${RED} AppName: $app${NC}"
mkdir -p debloate_${app}
pushd debloate_${app}

cp $appFullPath ${app}_orig.bc

echo -e "${RED} Run Neck Identification...${NC}"
start=`date +%s`

../neck-identification/build/tools/neck/neck -m ${app}_orig.bc -c ../neck-identification/config/cmd-tool-config.json --annotate --function-local-points-to-info-wo-globals

end=`date +%s`
runtime=$((end-start))
echo -e "\nRun Neck Identification took: ${runtime}s!\n"

echo -e "${RED} Run Partial Interpreter...${NC}"
start=`date +%s`

$BIN/klee --libc=uclibc --posix-runtime --dump-file gbls.txt ${app}_orig_neck.ll $args
$BIN/klee --libc=uclibc --posix-runtime --dump-file bbs.txt --dump-bbs ${app}_orig_neck.ll $args

end=`date +%s`
runtime=$((end-start))
echo -e "\nRun Partial Interpreter took: ${runtime}s!\n"

echo -e "${RED} Run Constant Conversion...${NC}"
start=`date +%s`

#I add the file name to the stringVars to exclude the lines that contain the file name
bitcodeName=`basename $F`
sed -i "1i$bitcodeName" stringVarsLcl.txt
sed -i "1i$bitcodeName" stringVarsGbls.txt

opt -load $ROOTDIR/LLVM_Passes/build/Debloat/libLLVMDebloat.so -debloat \
    -gblInt=gbls.txt\
    -plocals=primitiveLocals.txt \
	-clocals=customizedLocals.txt\
    -ptrStructlocals=ptrToStructLocals.txt \
    -ptrToPrimLocals=ptrToPrimitiveLocals.txt \
    -stringVarsLcl=stringVarsLcl.txt  \
    -stringVarsGbl=stringVarsGbls.txt \
 	-bbfile=bbs.txt -appName=${app} ${app}_orig_neck.ll -verify -o ${app}_cc.bc

end=`date +%s`
runtime=$((end-start))
echo -e "\nRun Constant Conversion took: ${runtime}s!\n"

echo -e "${RED} Run MultiStage Simplifications...${NC}"
start=`date +%s`

opt -sccp -instsimplify ${app}_cc.bc -o ${app}_cp.bc
opt -strip -simplifycfg ${app}_cp.bc -o ${app}_ps.bc
opt -load $ROOTDIR/LLVM_Passes/build/Debloat/libLLVMDebloat.so -debloat -cleanUp \
    ${app}_ps.bc -verify -o ${app}_cu.bc

end=`date +%s`
runtime=$((end-start))
echo -e "\nRun MultiStage Simplifications took: ${runtime}s!\n"

echo -e "${RED} Generate binay files...${NC}"
start=`date +%s`

tcpdumpFlg=0
if [[ $app == *"tcpdump"* ]]
then
    clang ${app}_orig.bc -libverbs -o ${app}_orig
    clang ${app}_cc.bc -libverbs -o ${app}_cc
    clang ${app}_cp.bc -libverbs -o ${app}_cp
    clang ${app}_ps.bc -libverbs -o ${app}_ps
    clang ${app}_cu.bc -libverbs -o ${app}_cu
    tcpdumpFlg=1
fi


 
objdumpFlg=0
if [[ $app == *"objdump"* || $app == *"readelf"* ]]
then
    clang ${app}_orig.bc -ldl -o ${app}_orig
    clang ${app}_cc.bc -ldl -o ${app}_cc
    clang ${app}_cp.bc -ldl -o ${app}_cp
    clang ${app}_ps.bc -ldl -o ${app}_ps
    clang ${app}_cu.bc -ldl -o ${app}_cu
    objdumpFlg=1
fi

if [[ $tcpdumpFlg == 0 && $objdumpFlg == 0 ]]
then
   llc -filetype obj ${app}_orig.bc
   llc -filetype obj ${app}_cc.bc
   llc -filetype obj ${app}_cp.bc
   llc -filetype obj ${app}_ps.bc
   llc -filetype obj ${app}_cu.bc
fi


sortFlg=0
if [[ $app == *"sort"* ]]
then
   gcc -O2 -pthread ${app}_orig.o -o  ${app}_orig -no-pie
   gcc -O2 -pthread ${app}_cc.o -o  ${app}_cc -no-pie
   gcc -O2 -pthread ${app}_cp.o -o  ${app}_cp -no-pie
   gcc -O2 -pthread ${app}_ps.o -o ${app}_ps -no-pie
   sortFlg=1
fi


if [[ $sortFlg == 0 && $tcpdumpFlg == 0 && $objdumpFlg == 0 ]]
then
    gcc -O2 ${app}_orig.o -o  ${app}_orig -no-pie
    gcc -O2 ${app}_cc.o -o  ${app}_cc -no-pie
    gcc -O2 ${app}_cp.o -o  ${app}_cp -no-pie
    gcc -O2 ${app}_ps.o -o ${app}_ps -no-pie
    gcc -O2 ${app}_cu.o -o ${app}_cu -no-pie
fi

if [[ $app == *"knockd"* ]]
then
    clang ${app}_orig.bc -lpcap -o ${app}_orig
    clang ${app}_cc.bc -lpcap -o ${app}_cc
    clang ${app}_cp.bc -lpcap -o ${app}_cp
    clang ${app}_ps.bc -lpcap -o ${app}_ps
    clang ${app}_cu.bc -lpcap -o ${app}_cu
fi

runSize=`size ${app}_orig`
size_orig=`echo $runSize | cut -d ' ' -f10`
echo size_orig=${size_orig}

runSize=`size ${app}_cc`
size_cc=`echo $runSize | cut -d ' ' -f10`
echo size_cc=${size_cc}

runSize=`size ${app}_cp`
size_cp=`echo $runSize | cut -d ' ' -f10`
echo size_cp=${size_cp}

runSize=`size ${app}_ps`
size_ps=`echo $runSize | cut -d ' ' -f10`
echo size_ps=${size_ps}

runSize=`size ${app}_cu`
size_cu=`echo $runSize | cut -d ' ' -f10`
echo size_cu=${size_cu}

end=`date +%s`
runtime=$((end-start))
echo -e "\nGenerate binay files: ${runtime}s!\n"

echo -e "${RED} Collect Statistical info...${NC}"
start=`date +%s`

opt -load $ROOTDIR/LLVM_Passes/build/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_orig} -o /dev/null ${app}_orig.bc

opt -load $ROOTDIR/LLVM_Passes/build/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_cc} -o /dev/null ${app}_cc.bc

opt -load $ROOTDIR/LLVM_Passes/build/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_cp} -o /dev/null ${app}_cp.bc

opt -load $ROOTDIR/LLVM_Passes/build/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_ps} -o /dev/null ${app}_ps.bc

opt -load $ROOTDIR/LLVM_Passes/build/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_cu} -o /dev/null ${app}_cu.bc

#rm *.txt
#rm *.o 
popd

end=`date +%s`
runtime=$((end-start))
echo -e "\nCollect Statistical info took: ${runtime}s!\n"

# verify tests on coreutils

echo -e "${RED} Running verifier tests${NC}"
start=`date +%s`

cp debloate_${app}/${app}_orig benchmarks/binaries
cp debloate_${app}/${app}_cu benchmarks/binaries

pushd benchmarks/${app}

python3 run.py verify

popd

end=`date +%s`
runtime=$((end-start))
echo -e "\nRunning verifier tests took: ${runtime}s!\n"
