#!/bin/bash
#SBATCH --job-name=shapeit
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=6:00:00
#SBATCH --output=shapeit_%j.log

echo "$(date) start ${SLURM_JOB_ID}"

source ~/miniconda3/etc/profile.d/conda.sh

conda activate shapeit5

indir="./"
outdir="shapeit_phasing"
PREFIX="run1"   # <-- change this per run
GROUND_TRUTH="chr1_phased_sortedsamples.vcf.gz"
INPUT="merged379.minQ20.minDP5.maxDP60.vcf.gz"

mkdir -p ${outdir}/${PREFIX}

tabix -f ${INPUT}
tabix -f ${GROUND_TRUTH}
tabix -f ${indir}/merged379.minQ20.minDP5.maxDP60.vcf.gz

echo "Running SHAPEIT5 for chr1"
SHAPEIT5_phase_common \
  --input ${INPUT} \ls 
  --scaffold ${indir}/${INPUT}\
  --output ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.vcf.gz \
  --hmm-ne 2000
conda deactivate
conda activate whatshap-env
module load bcftools
bcftools index -t ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.vcf.gz

echo "Calculating switch errors for ${chr}"
whatshap compare \
  --switch-error-rate \
  --indels \
  ${GROUND_TRUTH} \
  ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.vcf.gz \
  > ${outdir}/${PREFIX}/${PREFIX}.switch_errors.txt

myjobs -j ${SLURM_JOB_ID}

