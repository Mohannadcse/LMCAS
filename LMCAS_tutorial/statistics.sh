cd debloate_$1
rm report.csv
runSize=`size $1_orig`
size_orig=`echo $runSize | cut -d ' ' -f10`
opt-6.0 -load /build/LLVM_Passes/Profiler/libLLVMPprofiler.so -Pprofiler -size=${size_orig} -o /dev/null $1_orig.bc
cat report.csv
cd ..
