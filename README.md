# Building LMCAS Docker Machine #

[![Docker](https://github.com/Mohannadcse/LMCAS_Docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Mohannadcse/LMCAS_Docker/actions/workflows/docker-publish.yml)


1. Clone the repository (or unzip the compressed file)
   `git clone https://github.com/Mohannadcse/LMCAS_Docker`
2. execute the following commands to build and run LMCAS. The build process takes sometime because it involves downloading and building both of LLVM and KLEE.

For Docker
```shell
docker build -t lmcas .
docker run -it lmcas
```

For a native Linux build,

```
./install.sh
./build.sh

# build Dataset and run LMCAS
./buildDataset.sh
./runAnalysis.sh --file:artifacts_bitcode/Dataset-1/wc.bc --args:-l
```

# Running LMCAS 
We provide the source code of the apps used in the evaluation `after adding the neck`. But you need to compile these programs using `wllvm`. To avoid compilation, we also provided the bitcode of these apps. So actually you don't need to do the whole program. The bitcode of the apps can be found under the directory `artifacts_bitcode`.

+ `buildDataset.sh`: can be used for building the apps using `wllvm`
+ `runAnalysis.sh`: can be used for running LMCAS analysis. You just need to provide the program bitcode. Follw the examples provided in the `runAnalysis.sh`. After running the analysis, a new directory will be created that contains all results belong to the debloated app. The directory name starts with `debloate_`.

For replicating our evaluation, you can run the analysis according to the settings mentioned in this [TABLE](https://sites.google.com/view/lmcas/home#h.r7u6w8uktrgc)

NOTE: our debloating strategy strategy relies on the fact that we can split the app into configuration part and main logic part. Therefore, the specialized programs are generated w.r.t the required functionality. For example, you want `wc` to only count number of lines i.e., `wc -l`. So you don't need to provide the file name to our script `runAnalysis.sh`, which makes the command as follows `./runAnalysis.sh --file:artifacts_bitcode/Dataset-1/wc.bc --args:-l` or `./runAnalysis.sh --file:artifacts_bitcode/Dataset-3/tcpdump.bc --args:"-i lo"`.

# Interpreting the Results
After running `LMCAS`, a directory will be created `debloate_<AppName>`. This directory contains a set of files that are generated while debloating the app. 

+ Files appended with `_cc`: represent the outcome of the constant conversion
+ Files appended with `_cp`: represent the outcome of the constant propagation
+ Files appended with `_ps`: represent the outcome of the path simplification
+ Files appended with `_cu`: represent the outcome of the cleaning up. These files are the final results and represent the specialized app. Therefore, your testing should be on top of these files.
+ report.csv: contains profiling information summary about different statistics after finishing each simplification step. 

# Testing the specialized app
For testing the specialized app generated by our tool, you just need to run the executable ends with `_cu`, but you don't need to provide the entire arguments. Specifically, you don't need to provide the supplied inputs in the debloating process. For example, to rung the debloated `wc_cu`, you just need to provide the file name, because the line count option `-l` is already supplied to our debloating script script `runAnalysis.sh`. 


# Verification of debloated programs

This verification is also run as a part of `runAnalysis.sh`. To independently run the 
verification tests, please follow the guide.

Under each directory in `benchmarks/`:

NOTE: This step assumes that the original binary and the debloated binary are present in 
`benchmarks/binaries` with the following suffix 
- `<app>_orig`
- `<app>_cu`

For eg, for `basename`,

0. From the project root, 
    - `cd benchmarks/basename`

1. Run cases on original binary:
	- `python3 run.py original`

2. Run cases on debloated binary:
	- `python3 run.py debloated`
	- Further cases can be added in the corresponding run.py file.
	- Make sure the cases are added for both original and debloated binaries.

3. Verify if the both the cases match:
	- `python3 run.py verify`

4. Measure time and memory of the original and debloated binary
	- `python3 run.py measure`


# Measure time and memory

To measure the timing and memory usage information of the LMCAS pipeline 

```
./measureDataset1.sh                                 

        Elapsed (wall clock) time (h:mm:ss or m:ss): 2:50.56
        Maximum resident set size (kbytes): 184180
        Average resident set size (kbytes): 0 
```

To measure the timing and memory usage information of the original and debloated app, check the previous section


# Citation
```
@INPROCEEDINGS{LMCAS,
  title={Lightweight, Multi-Stage, Compiler-Assisted Application Specialization},
  author={Alhanahnah, Mohannad and Jain, Rithik and Rastogi, Vaibhav and Jha, Somesh and Reps, Thomas},
  booktitle={2022 IEEE 7th European Symposium on Security and Privacy (EuroS\&P)},
  pages={251--269},
  year={2022},
  organization={IEEE}
}
```
