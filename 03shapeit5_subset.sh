#!/bin/bash
#SBATCH --job-name=shapeit
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=24:00:00
#SBATCH --output=shapeit_%j.log

# usage: sbatch this_script.sh samples_iran.txt
SAMPLE_FILE="$1"
PREFIX=$(basename "$SAMPLE_FILE" .txt)   # e.g. samples_iran -> samples_iran

echo "$(date) start ${SLURM_JOB_ID} - group: ${PREFIX}"

source ~/miniconda3/etc/profile.d/conda.sh

indir="./"
outdir="phasing/"
GROUND_TRUTH="merged379.minQ20.minDP5.maxDP60.chr1_20MB.vcf.gz"
INPUT="data/chr1_unphased_20Mb.vcf.gz"

mkdir -p ${outdir}/${PREFIX}
cp "$0" ${outdir}/${PREFIX}/
cp "${SAMPLE_FILE}" ${outdir}/${PREFIX}/

module load bcftools

# subset the unphased input to just the samples in this group
SUBSET_INPUT="${outdir}/${PREFIX}/${PREFIX}.input_subset.vcf.gz"
bcftools view -S "${SAMPLE_FILE}" ${INPUT} -O z -o ${SUBSET_INPUT}
bcftools index -t ${SUBSET_INPUT}

conda activate shapeit5

tabix -f ${SUBSET_INPUT}
tabix -f ${GROUND_TRUTH}

echo "Running SHAPEIT5 for chr1"
SHAPEIT5_phase_common \
  --input ${SUBSET_INPUT} \
  --region chr1 \
  --output ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.bcf \
  --hmm-ne 20000
conda deactivate


conda activate whatshap-env
module load bcftools
bcftools index -t ${outdir}/${PREFIX}/${PREFIX}.shapeit5_phased.bcf

cat "${SAMPLE_FILE}" | while IFS= read -r SAMPLE; do

  ## subsetting the ground truth to only the phased sites in it
  bcftools view -s $SAMPLE ${GROUND_TRUTH} -Ou \
  | bcftools view -Ov \
  | awk -F'\t' 'BEGIN{OFS="\t"} /^#/ {print; next} $10 ~ /\|/ {print}' \
  | bgzip > ${outdir}/${PREFIX}/${SAMPLE}.ground_truth.vcf.gz

  bcftools index ${outdir}/${PREFIX}/${SAMPLE}.ground_truth.vcf.gz

  ## subsetting the phased shapeit file to only sites in the ground truth
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

grep "switch error rate" ${outdir}/${PREFIX}/*switch* | uniq > ${outdir}/${PREFIX}_summary_switch_errors.txt

echo "$(date) done ${SLURM_JOB_ID} - group: ${PREFIX}"