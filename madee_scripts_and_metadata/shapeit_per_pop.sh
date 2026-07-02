#!/bin/bash
#SBATCH --job-name=shapeit_bypop
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=4:00:00
#SBATCH --output=shapeit_bypop_%A_%a.log
#SBATCH --array=0-39  # 40 pops with >=3 individuals

echo "$(date) start ${SLURM_JOB_ID}"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate shapeit5
module load bcftools
# Populations with >=3 individuals, in order
POPS=(
  RO-SIT KZ-MAN BU-KAL IR-KIL IR-BAL IR-FIR IR-SHA GEO-CHA
  CN-XS GEO-DGJ IR-QAZ KZ-ATY AZ-ALT GEO-VAR IT-GRA OEN-CYP
  RO-CHE GEO-VVI IS-JUD BA-TRE E-GUI GR-LES IR-TAB TR-NIG
  AZ-QKH IR-ARD IR-HAS IR-QUC RU-TUV BU-BAL BU-KRO IS-HER
  KZ-IND TR-BUR CN-GAN CN-XIN IR-ASH MG-DOR-BUR MN-ULC RU-KRA
)

POP=${POPS[$SLURM_ARRAY_TASK_ID]}

indir="./"
outdir="shapeit_phasing"
SAMPLES="samples.txt"
GROUND_TRUTH="chr1_phased_sortedsamples.chr1_20MB.vcf.gz"
INPUT="merged379.minQ20.minDP5.maxDP60.chr1_20MB.vcf.gz"

mkdir -p ${outdir}/${POP}

# Extract sample list for this pop
grep "^${POP}-" ${SAMPLES} > ${outdir}/${POP}/pop_samples.txt
SAMPLE_LIST=$(cat ${outdir}/${POP}/pop_samples.txt | tr '\n' ',' | sed 's/,$//')

echo "Pop: ${POP}, samples: $(wc -l < ${outdir}/${POP}/pop_samples.txt)"

# Subset VCF to this pop
bcftools view -s ${SAMPLE_LIST} ${INPUT} -O z -o ${outdir}/${POP}/input_${POP}.vcf.gz
tabix -f ${outdir}/${POP}/input_${POP}.vcf.gz

bcftools view -s ${SAMPLE_LIST} ${GROUND_TRUTH} -O z -o ${outdir}/${POP}/ground_truth_${POP}.vcf.gz
tabix -f ${outdir}/${POP}/ground_truth_${POP}.vcf.gz

# Phase
conda activate shapeit5

echo "Running SHAPEIT5 for ${POP}"
SHAPEIT5_phase_common \
  --input ${outdir}/${POP}/input_${POP}.vcf.gz \
  --region chr1 \
  --output ${outdir}/${POP}/${POP}.shapeit5_phased.bcf \
  --hmm-ne 20000

conda deactivate
conda activate whatshap-env
module load bcftools

bcftools index -t ${outdir}/${POP}/${POP}.shapeit5_phased.bcf

# Switch errors per sample
while IFS= read -r SAMPLE; do
  echo "Subsetting $SAMPLE..."
  bcftools view -s ${SAMPLE} \
    ${outdir}/${POP}/${POP}.shapeit5_phased.bcf \
    -O z -o ${outdir}/${POP}/${SAMPLE}.phased.vcf.gz
  bcftools index ${outdir}/${POP}/${SAMPLE}.phased.vcf.gz

  bcftools view -s ${SAMPLE} \
    ${outdir}/${POP}/ground_truth_${POP}.vcf.gz \
    -O z -o ${outdir}/${POP}/${SAMPLE}.ground_truth.vcf.gz
  bcftools index ${outdir}/${POP}/${SAMPLE}.ground_truth.vcf.gz

  echo "Comparing $SAMPLE..."
  whatshap compare \
    ${outdir}/${POP}/${SAMPLE}.ground_truth.vcf.gz \
    ${outdir}/${POP}/${SAMPLE}.phased.vcf.gz \
    > ${outdir}/${POP}/${POP}.${SAMPLE}.switch_errors.txt
done < ${outdir}/${POP}/pop_samples.txt

grep "switch error rate" ${outdir}/${POP}/*switch* | uniq > summary_switch_errors_${POP}.txt

myjobs -j ${SLURM_JOB_ID}