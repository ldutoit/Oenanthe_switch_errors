#!/bin/bash   
#SBATCH --job-name=whatshap           #Name of the job   
#SBATCH --ntasks=1               #Requesting 1 node (is always 1)
#SBATCH --cpus-per-task=1        #Requesting 1 CPU
#SBATCH --mem-per-cpu=3G         #Requesting 1 Gb memory  
#SBATCH --time=4:00:00           #Requesting 4 hours running time 
#SBATCH --output whatshap_%a_%j.log          #Log
#SBATCH --array=2-84%10         #Run array job

echo "$(date) start ${SLURM_JOB_ID}"

## Set input directory
vcfin=var_data
vcfout=whatshap_phase
#Internal job index variable (1-78)
IDX=$SLURM_ARRAY_TASK_ID

samp=`sed -n ${IDX}p samp_list_pop_info.txt | cut -f1`

for chr_idx in {2..29}
do
chr=scaffold_${chr_idx}
vcftools --gzvcf ${vcfin}/autosomes.minQ20.minDP5.maxDP60.SNP.max_miss_20_perc.vcf.gz --chr ${chr} --indv ${samp} --recode --recode-INFO-all --stdout > ${vcfin}/${samp}.${chr}.vcf
whatshap  phase -o ${vcfout}/${chr}.${samp}.minQ20.minDP5.maxDP60.SNP.whatshap_phased.vcf --sample ${samp} --chromosome ${chr} --reference genomes/milMil_1.3_rep1.fasta ${vcfin}/${samp}.${chr}.vcf mapping/dedup_bam/${samp}*.bam
done

rm ${vcfin}/${samp}.scaffold_*.vcf
##############################################
##Get a summary of the job 
myjobs -j ${SLURM_JOB_ID}
##############################################