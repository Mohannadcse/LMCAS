runSize=`size $1_orig`
/size_orig=`echo $runSize | cut -d ' ' -f12`
/opt-6.0 -load /build/LLVM_Passes/Profiler/libLLVMPprofiler.so -Pprofiler -size=${size_orig} -o /dev/null $1_orig.bc
