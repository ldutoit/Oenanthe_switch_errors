#README

The goal is to assess whether linked-reads are needed for phasing in the Oenanthe Genoscape project.

We are only comparing the phased via whatshap to the phase via shapeit without whatshap from data of the Science paper.

## Reference panel information
 
`Population-wise_phasing.xlsx` has the information on how the population specific reference panels were specified. For samples sequenced with regular Illumina it specifies the population of the sample and the reference panel population. For samples with 10x data it gives the reference panel population name.
 
Note: this file likely contains more samples than are actually in the phased VCFs shared.
 
## Pipeline
 
Phasing is run separately for the first 20MB of chromosome. The steps are:
 
01. **WhatsHap** — run separately per sample. Provide a ground truth, for a subset of site per sample.
02. **Merge** — WhatsHap output for all samples for one chromosome is merged before running SHAPEIT.
03. **SHAPEIT5** — run per chromosome. We are only comparing the phased via whatshap to the phase via shapeit without whatshap. Shape it report an error if N <50, so we can't do below 50.
04. **Summarize** — summarize the number of variants and the switch error rates.
05. **plots and stats** — plots and stats

## Summary

The summary is within the [05_phasing_errors.md](05_phasing_errors.md). Some population work a lot better than others. 1% error for Romania, versus >30% for some *hispanica*. When we only use subpopulation of slightly over 50 individuals to phase (but with less structure), phasing gets worse (1% worse for Romania, 5% for Iran or *melanoleuca*). It seems total numbers of individuals to phase really matter.

We decided: 
    - We will try without haplotagging for the bulk, with a subsample going for phasing anyway (but we might get data later). 
    - From that data, we will be able to compare paired-end reads to statistical phasing.
    - Stuff we can do, in order of usefulness; 1. Simulating pased data with Slim using pop structure of Northern wheatear to assess experimental design. 2. Play with Ne with phasing. 3. 3-way comparison: paired-end reads vs shapeit vs linked reads.

    