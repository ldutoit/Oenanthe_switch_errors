Madee's notes (Team June 8 2026)

Population-wise_phasing.xlsx  has the information on how the population specific reference panels were specified
 
For samples that were sequenced with regular illumina it specifies the population of the sample, and the reference panel population, and for the samples with 10x data it gives the reference panel population name
 
The one thing, is I think this contains more samples than are actually in the phased vcfs I shared with you
 
And examples of whatshap and shapeit. These are both run separately per chromosome, and whatshap was run separately per sample. I think theoretically you should be able to provide a population vcf and just give which sample you want to analyze as a parameter, but I had issues with this for some reason so I just subset the vcf to a single sample first. And for shapeit, I specified Ne as a parameter, this was for red kite which is why it's only 20,000 
whatshap_phase.sh
shapeit5.sh
 
In between these scripts, I merge the whatshap output for all samples for one chromosome to run in shapeit
 
