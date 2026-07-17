## Set up

'''
mkdir data
cd data
'''

Copy over one chromosome

'''
ln -s /cluster/work/gdc/shared/p757/data/oenanthe/data/popgen_10XG_Illumina_Museum/data_analysis/phased_data_chromosomes/merged_allsamples/phased_sorted/chr1_phased_sortedsamples.vcf.gz
'''

## Unphasing (Note, there seems to be no missing data)

'''
module load stack/.2024-05-silent gcc/13.2.0 bwa/0.7.17 stack/.2024-03-beta-silent gcc/13.2.0-i6mrihr samtools/1.17-7ay44i2
zcat chr1_phased_sortedsamples.vcf.gz | sed 's/|/\//g'   |  gzip -c > chr1_unphased.vcf.gz
'''

Checking it worked and that we have a valid vcf

```
module load       stack/.2024-05-silent  gcc/13.2.0 vcftools/0.1.16-tc6l6nq
vcftools --gzvcf chr1_unphased.vcf.gz 
#457215 SNPs
```

ref genome:

```
ln -s ~/p757/data/genomes/by-refmake/Oenanthe_melanoleuca/OenMel1.1/OenMel1.1/oenMel1.1.fasta.gz .
gunzip oenMel1.1.fasta.gz -c > oenMel1.1.fasta
module load      stack/.2024-05-silent  gcc/13.2.0  bwa/0.7.17  stack/.2024-03-beta-silent  gcc/13.2.0-i6mrihr samtools/1.17-7ay44i2
samtools faidx oenMel1.1.fasta
```

```
# first 20 million bases (POS 1-20000000) of chr1
module load bcftools
cd data
bcftools view -r chr1:1-20000000 chr1_unphased.vcf.gz -Oz -o chr1_unphased_20Mb.vcf.gz
tabix -p vcf chr1_unphased_20Mb.vcf.gz
bcftools index chr1_unphased_20Mb.vcf.gz
````