#!/bin/bash
# Preliminary Results Commands - Kraken2 Analysis
# This script records all commands used to run Kraken2 for taxonomic classification.

# Step 1: Download the pre-built 8GB Kraken2 database
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20241228.tar.gz


# Step 2: Extract the downloaded database
tar -xvzf k2_standard_8gb_20240306.tar.gz

# Step 3: Create Conda environment for Kraken2 (MacOS-specific architecture forced)
CONDA_SUBDIR=osx-64 conda create -n kraken2 -y

# Step 4: Activate Conda environment
conda activate kraken2

# Step 5: Install Kraken2 using Bioconda and Conda-Forge channels
conda install -c bioconda -c conda-forge kraken2

# Step 6: Run Kraken2 classification for sample B1299860
kraken2 \
--db ./k2_standard_08gb_20240306 \
--threads 8 \
--output B1299860.kraken2.output \
--report B1299860.kraken2.report \
B1299860_S01_L001_contigs.fasta

# Step 7: (Optional) Check number of contigs in the FASTA file
grep '>' B1299860_S01_L001_contigs.fasta | wc -l

# Step 8: Run Kraken2 classification for sample B1838859 (second sample)
kraken2 \
--db ./k2_standard_08gb_20240306 \
--threads 8 \
--output B1838859.kraken2.output \
--report B1838859.kraken2.report \
B1838859_S01_L001_contigs.fa

# Step 9: (Optional) Check number of contigs in the second FASTA file
grep '>' B1838859_S01_L001_contigs.fa | wc -l

# Step 10: Confirm results (check first few lines of each output)
head -5 B1299860.kraken2.output
head -10 B1299860.kraken2.report
head -5 B1838859.kraken2.output
head -10 B1838859.kraken2.report

# Note:
# - This file should be kept inside the repository (e.g., under `preliminary/` folder).
# - This log helps the team and graders understand exactly how the analysis was conducted.
# - If there are any changes (e.g., parameter tuning), update this file immediately.
