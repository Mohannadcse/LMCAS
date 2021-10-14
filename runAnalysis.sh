#!/bin/bash

LLVM_VERSION=10

function usage()
{
    echo "Syntax: ./runAnalysis.sh --file=path/to/bitcode.bc --args=partial inputs"
    echo "if there are spaces in the partial inputs, then please use double qutation"
    echo "Examples: "
    echo "./runAnalysis.sh --file:wc.bc --args:-l"
    echo "./runAnalysis.sh --file:tcpdump.bc --args:\"-i lo\" "
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
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            ;;
    esac
    shift
done

if [ "$F" == "" ] || [ "$args" == "" ]; then
    usage
fi

echo "Bitcode File is $F";
echo "Args is $args";

app=$(basename $F .bc)
appFullPath=$(realpath $F)

echo "AppName: $app"
mkdir debloate_${app}
cd debloate_${app}

cp $appFullPath ${app}_orig.bc

echo "Run KLEE..."

klee --libc=uclibc --posix-runtime --dump-file gbls.txt $appFullPath $args
klee --libc=uclibc --posix-runtime --dump-file bbs.txt --dump-bbs $appFullPath $args

#I add the file name to the stringVars to exclude the lines that contain the file name
bitcodeName=`basename $F`
sed -i "1i$bitcodeName" stringVars.txt

echo "Run Constant Conversion..."
opt-${LLVM_VERSION} -load /build/LLVM_Passes/Debloat/libLLVMDebloat.so -debloat \
    -globals=gbls.txt\
    -plocals=primitiveLocals.txt \
	-clocals=customizedLocals.txt\
    -ptrStructlocals=ptrToStructLocals.txt \
    -ptrToPrimLocals=ptrToPrimitiveLocals.txt \
    -stringVars=stringVars.txt  \
 	-bbfile=bbs.txt -appName=${app} ${app}_orig.bc -verify -o ${app}_cc.bc

echo "Run MultiStage Simplifications..."
opt-${LLVM_VERSION} -constprop ${app}_cc.bc -o ${app}_cp.bc
opt-${LLVM_VERSION} -strip -simplifycfg ${app}_cp.bc -o ${app}_ps.bc
opt-${LLVM_VERSION} -load /build/LLVM_Passes/Debloat/libLLVMDebloat.so -debloat -cleanUp \
    ${app}_ps.bc -verify -o ${app}_cu.bc


echo "Generate binay files..."

tcpdumpFlg=0
if [[ $app == *"tcpdump"* ]]
then
    clang-${LLVM_VERSION} ${app}_orig.bc -libverbs -o ${app}_orig
    clang-${LLVM_VERSION} ${app}_cc.bc -libverbs -o ${app}_cc
    clang-${LLVM_VERSION} ${app}_cp.bc -libverbs -o ${app}_cp
    clang-${LLVM_VERSION} ${app}_ps.bc -libverbs -o ${app}_ps
    clang-${LLVM_VERSION} ${app}_cu.bc -libverbs -o ${app}_cu
    tcpdumpFlg=1
fi


 
objdumpFlg=0
if [[ $app == *"objdump"* || $app == *"readelf"* ]]
then
    clang-${LLVM_VERSION} ${app}_orig.bc -ldl -o ${app}_orig
    clang-${LLVM_VERSION} ${app}_cc.bc -ldl -o ${app}_cc
    clang-${LLVM_VERSION} ${app}_cp.bc -ldl -o ${app}_cp
    clang-${LLVM_VERSION} ${app}_ps.bc -ldl -o ${app}_ps
    clang-${LLVM_VERSION} ${app}_cu.bc -ldl -o ${app}_cu
    objdumpFlg=1
fi

if [[ $tcpdumpFlg == 0 && $objdumpFlg == 0 ]]
then
   llc-${LLVM_VERSION} -filetype obj ${app}_orig.bc
   llc-${LLVM_VERSION} -filetype obj ${app}_cc.bc
   llc-${LLVM_VERSION} -filetype obj ${app}_cp.bc
   llc-${LLVM_VERSION} -filetype obj ${app}_ps.bc
   llc-${LLVM_VERSION} -filetype obj ${app}_cu.bc
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


echo "Collect Statistical info..."
opt-${LLVM_VERSION} -load /build/LLVM_Passes/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_orig} -o /dev/null ${app}_orig.bc

opt-${LLVM_VERSION} -load /build/LLVM_Passes/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_cc} -o /dev/null ${app}_cc.bc

opt-${LLVM_VERSION} -load /build/LLVM_Passes/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_cp} -o /dev/null ${app}_cp.bc

opt-${LLVM_VERSION} -load /build/LLVM_Passes/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_ps} -o /dev/null ${app}_ps.bc

opt-${LLVM_VERSION} -load /build/LLVM_Passes/Profiler/libLLVMPprofiler.so \
 -Pprofiler -size=${size_cu} -o /dev/null ${app}_cu.bc

#rm *.txt
#rm *.o 
