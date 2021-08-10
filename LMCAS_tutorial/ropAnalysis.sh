#/bin/bash
# total gadgets: ropgadget --binary prog
# only jop:      ropgadget --binary --norop --nosys
# only sys:      ropgadget --binary --nojop --norop
# only rop:      ropgadget --binary --nojop --nosys
# $1: binary file
# $2: name of the CSV where the results will be stored
#echo "FILE: $1"
fbname=$(basename "$1")
total=-1
onlyJOP=-1
onlySYS=-1
onlyROP=-1
#echo "Compute TOTAL"
ROPgadget --binary $1 > tmp.txt
total=`tail -1 tmp.txt | cut -d ' ' -f4`
#echo "Compute ONLY JOP"
ROPgadget --norop --nosys --binary $1 > tmp.txt
onlyJOP=`tail -1 tmp.txt | cut -d ' ' -f4`
#echo "Compute ONLY SYS"
ROPgadget --nojop --norop --binary $1 > tmp.txt
onlySYS=`tail -1 tmp.txt | cut -d ' ' -f4`
#echo "Compute ONLY ROP"
ROPgadget --nojop --nosys --binary $1 > tmp.txt
onlyROP=`tail -1 tmp.txt | cut -d ' ' -f4`
echo $fbname,$total,$onlyJOP,$onlySYS,$onlyROP >> ${2}.csv
tail -1 tmp.txt
