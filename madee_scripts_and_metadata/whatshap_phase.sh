#!/bin/bash   
#SBATCH --job-name=whatshap           #Name of the job   
#SBATCH --ntasks=1               #Requesting 1 node (is always 1)
#SBATCH --cpus-per-task=1        #Requesting 1 CPU
#SBATCH --mem-per-cpu=56G         #Requesting 1 Gb memory  
#SBATCH --time=8:00:00           #Requesting 4 hours running time 
#SBATCH --output logs/whatshap_%a_%j.log          #Log
#SBATCH --array=1-379%40         #Run array job
module load       stack/.2024-05-silent  gcc/13.2.0 vcftools/0.1.16-tc6l6nq
source ~/miniconda3/etc/profile.d/conda.sh

conda activate whatshap-env
echo "$(date) start ${SLURM_JOB_ID}"
chr="chr1"
## Set input directory

vcfout=whatshap_phase
#Internal job index variable (1-78)
IDX=$SLURM_ARRAY_TASK_ID

mkdir -p ${vcfout}
samp=$(awk "NR==${IDX}" ~/git/Oenanthe_switch_errors/samples.txt)

mkdir -p ${vcfout}
samp=$(awk "NR==${IDX}" ~/git/Oenanthe_switch_errors/samples.txt)
echo $samp


vcftools --gzvcf data/chr1_unphased.vcf.gz --chr ${chr} --indv ${samp} --recode --recode-INFO-all --stdout > ${vcfout}/${samp}.${chr}.vcf
whatshap  phase -o ${vcfout}/${chr}.${samp}.whatshap_phased.vcf --sample ${samp} --chromosome ${chr} --reference data/oenMel1.1.fasta ${vcfout}/${samp}.${chr}.vcf /cluster/work/gdc/shared/p757/data/oenanthe/data/popgen_10XG_Illumina_Museum/10XG_data/bam_files/${samp}.RG.recalibrated.bam  && touch logs/${chr}.${samp}.whatshap.done


#rm ${vcfout}/${samp}.scaffold_*.vcf
##############################################
##Get a summary of the job 
myjobs -j ${SLURM_JOB_ID}
##############################################