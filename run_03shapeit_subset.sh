cat samples.txt | grep "^IR" > samples_iran.txt # 84
cat samples.txt | grep "^RO"  > samples_roandBUKAL.txt
cat samples.txt | grep "^BU-KAL" >> samples_roandBUKAL.txt # 65
cat samples.txt | grep -E "^IT|^GR|^MN|^BA|^IS"  > samples_melanoleuca.txt #Isreal was needed

 sbatch shapeit_run.sh "$f"


for f in samples_iran.txt samples_roandBUKAL.txt samples_melanoleuca.txt; do
  sbatch 03shapeit5_subset.sh "$f"
done