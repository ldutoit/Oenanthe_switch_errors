# Maddie's notes (Team June 8 2026)
 
## Reference panel information
 
`Population-wise_phasing.xlsx` has the information on how the population specific reference panels were specified.
 
For samples sequenced with regular Illumina it specifies the population of the sample and the reference panel population. For samples with 10x data it gives the reference panel population name.
 
Note: this file likely contains more samples than are actually in the phased VCFs shared.
 
## Pipeline
 
Phasing is run separately per chromosome. The steps are:
 
1. **WhatsHap** — run separately per sample. Theoretically you can provide a population VCF and specify which sample to analyze as a parameter, but this caused issues so the VCF was subset to a single sample first.
2. **Merge** — WhatsHap output for all samples for one chromosome is merged before running SHAPEIT.
3. **SHAPEIT5** — run per chromosome on the merged file. `Ne` was specified as a parameter (set to 20,000 here, as this was for red kite).
## Scripts
 
- `whatshap_phase.sh`
- `shapeit5.sh`
 
