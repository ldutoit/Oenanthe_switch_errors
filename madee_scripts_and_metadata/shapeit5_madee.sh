#!/bin/bash   
#SBATCH --job-name=shapeit          #Name of the job   
#SBATCH --ntasks=1               #Requesting 1 node (is always 1)
#SBATCH --cpus-per-task=1        #Requesting 1 CPU
#SBATCH --mem-per-cpu=1G         #Requesting 1 Gb memory  
#SBATCH --time=4:00:00           #Requesting 4 hours running time 
#SBATCH --output shapeit_%j.log          #Log

echo "$(date) start ${SLURM_JOB_ID}"


## Set input directories
indir="whatshap_phase"
outdir="shapeit_phasing"
for IDX in {13..29}
do
## Get chromosome name
chr="scaffold_${IDX}"

tabix -f ${indir}/merged_samples.${chr}.minQ20.minDP5.maxDP60.SNP.whatshap_phased.vcf.gz

# Phase population data
echo "Running shapeit for ${chr}"
~/bin/phase_common_static -I ${indir}/merged_samples.${chr}.minQ20.minDP5.maxDP60.SNP.whatshap_phased.vcf.gz --region ${chr} -O ${outdir}/merged_samples.${chr}.minQ20.minDP5.maxDP60.SNP.whatshap_phased.shapeit_out.bcf --hmm-ne 20000
done

##############################################
##Get a summary of the job 
myjobs -j ${SLURM_JOB_ID}
##############################################