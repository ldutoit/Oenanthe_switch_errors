# Oenanthe Switch Errors

**Do we actually need haplotagging?**

This project evaluates whether haplotagging (10x Genomics linked-read phasing) meaningfully improves phasing accuracy over statistical phasing alone — or whether modern statistical methods, combined with within-read physical phasing, are sufficient.

## Background

The core question: can we get away without haplotagging in new datasets?

We expect statistical phasing to perform *better* in the new data than in Dave's dataset, because:
- We have substantially more data
- There is less population structure

This means our comparison will likely be **conservative** — if statistical phasing holds up well even against Dave's haplotagged data, it should do even better in the new context.

## Pipeline
.
## Approach

1. **Strip haplotagging from Dave's data** and re-phase using physical methods in short-reads (WHATSHAP) + Statistical (SHAPEIT) only
2. **Compare accuracy** against the fully phased ground truth (WHATSHAP)
3. Use the result as a lower bound, the new data should do at least this well, likely better.
## Data

### Fully phased data (WhatsHap + SHAPEIT + haplotagging)

Dave's dataset — some individuals sequenced at 10x coverage, some with reference panels.

```
/cluster/work/gdc/shared/p757/data/oenanthe/data/popgen_10XG_Illumina_Museum/data_analysis/phased_data_chromosomes/merged_allsamples/phased_sorted
```

### Physical phasing only (ground truth for comparison)

Samples with within-read physical linkage only, no statistical phasing.

> ⬜ Maddie to send

### Reference panel populations

> ⬜ Maddie to send — which populations used reference panels?


## Additional Ideas

- **Simulations** — model phasing accuracy under varying conditions
- **Downsampling curve** — phase from progressively smaller subsets of the dataset to characterise the accuracy-vs-sample-size curve, and extrapolate beyond the current data range


| Simulations | ⬜ Optional |
| Downsampling curve, will give us an idea of how upsampling will look like | ⬜ Optional |

## NOTE from Madee

Another heads up, there is one sample that has been mislabelled (both in the vcf and for the bam file). The sample is called OEN-CYP-C6A298021 according to the vcf/bam, but should actually be GR-DAD-C6A298021. In the list of sample names for phasing I sent you it is referred to as that but I've added a note now.
 
Basically important to note that this is a melanoleuca sample and not cypriaca as the name refers to... but probably not that important for what you're doing.
 