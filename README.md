# Maddie's notes (Team June 8 2026)
 
## Reference panel information
 
`Population-wise_phasing.xlsx` has the information on how the population specific reference panels were specified.
 
For samples sequenced with regular Illumina it specifies the population of the sample and the reference panel population. For samples with 10x data it gives the reference panel population name.
 
Note: this file likely contains more samples than are actually in the phased VCFs shared.
 
## Pipeline
 
Phasing is run separately for the first 20MB of chromosome. The steps are:
 
01. **WhatsHap** — run separately per sample. Provide a ground truth, for a subset of site per sample.
02. **Merge** — WhatsHap output for all samples for one chromosome is merged before running SHAPEIT.
03. **SHAPEIT5** — run per chromosome. We areonly comparing the phased via whatshap to the phase via shapeit without whatshap. Shape it report an error if N <50, so we can't do below 50.
04. **Summarize** — summarize the number of variants and the switch error rates.
05. **plots and stats** — plots and stats

##

Is it per pop size, or distance to reference genome?

what about my Ne
