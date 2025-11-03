This is the home for mash final results. Mash was run on all 34 isolates to taxonomically identify them to the genus level.

# Final Results
All 34 isolates were run with mash and computed to have an average ANI with the reference genome (N. gonorrehea 1090) of 99.6. Computations to derive ANI from calculated mash distance done in R (R script included in this directory).

## Command Line Input
```bash
mash dist <assembly_directory>/*.fa <reference_genome>.fa
```
## Command Line Output Example
```bash
group3/reference.fna	B2/final_contigs/B0993986_S01_L001_contigs.fa	0.00396608	0	852/1000
```

