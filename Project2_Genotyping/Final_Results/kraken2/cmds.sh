#!/bin/bash

# --------------------------------------------
# Kraken2 Full Workflow Script
# Author: bbeominfo
# Description: Full pipeline for taxonomic classification
#             and visualization of metagenomic samples
# --------------------------------------------
# 0. Envrionment setting
# CONDA_SUBDIR=osx-64 conda create -n kraken2 -y

# conda activate kraken2 
# conda install -c bioconda -c conda-forge kraken2 -y
# 1. Kraken2 database download and build
# (Only need to run once)
# mkdir -p kraken_db
# wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_8gb_20241228.tar.gz

# 2. Run Kraken2 classification on all input files
INPUT_DIR="./final_contigs"
OUTPUT_DIR="./kraken_output"
THREADS=8
mkdir -p "$OUTPUT_DIR"

for file in $INPUT_DIR/*_contigs.fa*; do
    filename=$(basename "$file")
    prefix=${filename%%_contigs*}
    
    kraken2 \
        --db ./kraken_db/k2_standard_08gb_20241228 \
        --threads "$THREADS" \
        --report "$OUTPUT_DIR/${prefix}.kraken2.report" \
        --output "$OUTPUT_DIR/${prefix}.kraken2.output" \
        "$file"
done

# 3. Parse Kraken2 report files into clean TSVs
mkdir -p parsed_reports

for report in $OUTPUT_DIR/*.kraken2.report; do
    sample=$(basename "$report" .kraken2.report)
    
    {
        echo -e "Percentage\tFragmentsCovered\tFragmentsAssigned\tRank\tTaxID\tName"
        awk -F '\t' 'NF==6 {
            gsub(/^[ \t]+/, "", $6);  # Name 좌측 공백 제거
            printf "%.2f\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5, $6
        }' "$report"
    } > "parsed_reports/${sample}.parsed.tsv"
done

# 4. Install Krona & visualize Kraken2 output (Optional)
# conda install -c bioconda krona
# updateTaxonomy.sh
mkdir -p krona_html
for output in $OUTPUT_DIR/*.kraken2.output; do
    sample=$(basename "$output" .kraken2.output)
    cut -f2,3 "$output" > krona_html/${sample}.krona.input
    ktImportTaxonomy -o krona_html/${sample}.krona.html krona_html/${sample}.krona.input
done

# 5. Extract top 3 strain-level (S1) taxa from report files
OUTFILE="strain_summary/top3_strains.tsv"
mkdir -p strain_summary


echo -e "Sample\tS\tPerc\tS1\tPerc1\tS2\tPerc2" > "$OUTFILE"


for file in ./kraken_output/*.kraken2.report; do
    sample=$(basename "$file" .kraken2.report)

    s_line=$(awk -F '\t' '$4=="S"{print $6"\t"$1}' "$file" | sort -k2,2nr | head -n1)


    s1_lines=$(awk -F '\t' '$4=="S1"{print $6"\t"$1}' "$file" | sort -k2,2nr | head -n2)

    strain1=$(echo "$s_line" | cut -f1)
    perc1=$(echo "$s_line" | cut -f2)

    strain2=$(echo "$s1_lines" | sed -n 1p | cut -f1)
    perc2=$(echo "$s1_lines" | sed -n 1p | cut -f2)

    strain3=$(echo "$s1_lines" | sed -n 2p | cut -f1)
    perc3=$(echo "$s1_lines" | sed -n 2p | cut -f2)


    strain1=${strain1:-"NA"}
    perc1=${perc1:-"0"}
    strain2=${strain2:-"NA"}
    perc2=${perc2:-"0"}
    strain3=${strain3:-"NA"}
    perc3=${perc3:-"0"}

    echo -e "${sample}\t${strain1}\t${perc1}\t${strain2}\t${perc2}\t${strain3}\t${perc3}" >> "$OUTFILE"
done


# 6. Python script to visualize top 3 strains per sample as barplot
# Save this portion as "vis_top3_strains.py"

: <<'PYTHON'
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


df = pd.read_csv("top3_strains.tsv", sep="\t")


df_melted = pd.melt(
    df,
    id_vars=["Sample"],
    value_vars=["Strain1", "Strain2", "Strain3"],
    var_name="StrainRank",
    value_name="Strain"
)


perc_melted = pd.melt(
    df,
    id_vars=["Sample"],
    value_vars=["Perc1", "Perc2", "Perc3"],
    var_name="PercRank",
    value_name="Percentage"
)


df_long = df_melted.copy()
df_long["Percentage"] = perc_melted["Percentage"].astype(float)


plt.figure(figsize=(14, 6))
sns.barplot(
    data=df_long,
    x="Sample",
    y="Percentage",
    hue="Strain"
)
plt.xticks(rotation=90)
plt.ylabel("Percentage (%)")
plt.title("Top 3 Strains per Sample")
plt.tight_layout()
plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')

plt.savefig("top3_strains_barplot2.png", dpi=300)
plt.show()

PYTHON

# python vis_top3_strains.py
