#!/bin/bash
#SBATCH --job-name=shapeit
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=24:00:00
#SBATCH --output=shapeit_%j.log


#to subset
#bcftools view -r chr1:1-20000000 chr1_phased_sortedsamples.vcf.gz -O z -o chr1_phased_sortedsamples.chr1_20MB.vcf.gz
#bcftools view -r chr1:1-20000000 merged379.minQ20.minDP5.maxDP60.vcf.gz -O z -o merged379.minQ20.minDP5.maxDP60.chr1_20MB.vcf.gz

echo "$(date) start ${SLURM_JOB_ID}"

source ~/miniconda3/etc/profile.d/conda.sh

conda activate shapeit5

indir="./"
outdir="phasing/"
PREFIX="from_unphased"   # <-- change this per run
GROUND_TRUTH="merged379.minQ20.minDP5.maxDP60.chr1_20MB.vcf.gz" 
INPUT="data/chr1_unphased_20Mb.vcf.gz"

mkdir -p ${outdir}/${PREFIX}
cp "$0" ${outdir}/${PREFIX}/


tabix -f ${INPUT}
tabix -f ${GROUND_TRUTH}


echo "Running SHAPEIT5 for chr1"
SHAPEIT5_phase_common \
  --input ${INPUT} \
  --region chr1 \
  --output ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.bcf \
  --hmm-ne 20000
conda deactivate
 conda activate whatshap-env
 module load bcftools
bcftools index -t ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.bcf

# echo "Calculating switch errors for ${chr}"
cat samples.txt | while IFS= read -r SAMPLE; do


## subsetting the ground truth to only the phase sites in it
bcftools view -s $SAMPLE ${GROUND_TRUTH} -Ou \
| bcftools view -Ov \
| awk -F'\t' 'BEGIN{OFS="\t"} /^#/ {print; next} $10 ~ /\|/ {print}' \
| bgzip > ${outdir}/${PREFIX}/${SAMPLE}.ground_truth.vcf.gz

bcftools index ${outdir}/${PREFIX}/${SAMPLE}.ground_truth.vcf.gz


## subsetting the phase shapeit file to only site in the ground truth
echo "Subsetting $SAMPLE..."
bcftools view -s $SAMPLE \
  ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.bcf \
  -Ou \
| bcftools view -T ${outdir}/${PREFIX}/${SAMPLE}.ground_truth.vcf.gz \
  -O z -o ${outdir}/${PREFIX}/${SAMPLE}.phased.vcf.gz

bcftools index ${outdir}/${PREFIX}/${SAMPLE}.phased.vcf.gz



echo "Comparing $SAMPLE..."
whatshap compare \
  ${outdir}/${PREFIX}/${SAMPLE}.ground_truth.vcf.gz \
  ${outdir}/${PREFIX}/${SAMPLE}.phased.vcf.gz \
  > ${outdir}/${PREFIX}/${PREFIX}.${SAMPLE}.switch_errors.txt
done
myjobs -j ${SLURM_JOB_ID}


grep "switch error rate" ${outdir}/${PREFIX}/*switch* | uniq   > ${outdir}/${PREFIX}_summary_switch_errors.txt