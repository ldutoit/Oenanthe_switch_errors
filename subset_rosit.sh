#!/bin/bash
set -euo pipefail

module load bcftools   # adjust module name/version as needed

VCF1=merged379.minQ20.minDP5.maxDP60.chr1_20MB.vcf.gz
VCF2=data/chr1_unphased_20Mb.vcf.gz

# ── Step 1: get full sample list from VCF1 (source of truth for who's RO-SIT) ──
bcftools query -l ${VCF1} > all_samples.txt

# ── Step 2: split into RO-SIT/RO_SIT samples vs everyone else ─────────────────
grep -E '^RO[-_]SIT' all_samples.txt > rosit_samples.txt || true
grep -vE '^RO[-_]SIT' all_samples.txt > other_samples.txt

echo "Total samples: $(wc -l < all_samples.txt)"
echo "RO-SIT/RO_SIT samples found: $(wc -l < rosit_samples.txt)"
echo "Other samples: $(wc -l < other_samples.txt)"

# ── Step 3: randomly keep 10 of the RO-SIT/RO_SIT samples ─────────────────────
# (use head -n 10 instead of shuf if you want a reproducible/deterministic subset)
shuf -n 10 rosit_samples.txt > rosit_keep10.txt

echo "Keeping these 10 RO-SIT/RO_SIT samples:"
cat rosit_keep10.txt

# ── Step 4: build final keep list = all others + 10 RO-SIT/RO_SIT ─────────────
cat other_samples.txt rosit_keep10.txt > keep_samples.txt

echo "Final sample count to keep: $(wc -l < keep_samples.txt)"

# ── Step 5: apply the same sample list to both VCFs ────────────────────────────
bcftools view -S keep_samples.txt -Oz -o merged379.minQ20.minDP5.maxDP60.chr1_20MB.rosit10.vcf.gz ${VCF1}
bcftools index -t merged379.minQ20.minDP5.maxDP60.chr1_20MB.rosit10.vcf.gz

bcftools view -S keep_samples.txt -Oz -o chr1_phased_sortedsamples.rosit10.vcf.gz ${VCF2}
bcftools index -t chr1_phased_sortedsamples.rosit10.vcf.gz

echo "Done."