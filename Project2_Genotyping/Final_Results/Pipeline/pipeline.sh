#!/bin/bash
# Genotyping & Taxonomic Analysis & Assessment Pipeline
# Refer to the README.md for environment setup

set -e

# Ensure script gets correct inputs
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_dir> <output_dir> <kraken_db_path>"
    exit 1
fi

input_dir=$1
output_dir=$2
kraken_db_path=$3

# Check if required tools are installed 
for tool in mlst fastANI mash checkm kraken2 curl awk; do
    if ! command -v "$tool" &>/dev/null; then
        echo "Error: Required tool '$tool' is not installed or not in PATH."
        exit 1
    fi
done

# Create output directory for each tool
echo "Creating output directories..."
mkdir -p "${output_dir}/mlst"
mkdir -p "${output_dir}/fastani"
mkdir -p "${output_dir}/mash"
mkdir -p "${output_dir}/checkm"
mkdir -p "${output_dir}/kraken2"

# Download the reference genome
echo "Downloading reference genome..."
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/845/GCF_000006845.1_ASM684v1/GCF_000006845.1_ASM684v1_genomic.fna.gz
mv GCF_000006845.1_ASM684v1_genomic.fna.gz reference.fa # rename it for convenience
echo "Reference genome downloaded and renamed to reference.fa."

# fasta files in input directory
echo "Unzipping input fasta files..."
gunzip ${input_dir}/*
echo "Input files unzipped."


# 1. MLST analysis : Genotyping
echo "Starting mlst analysis..."
(
mlst "${input_dir}"/*.fa > "${output_dir}/mlst/mlst_summary.tsv"
)  2>&1 | tee "${output_dir}/mlst/mlst.log"
echo "MLST analysis completed."


# Taxanomic tool : ANI calculator for genus/species level
# 2. FastANI ANI Calculation
echo "Starting FastANI calculation..."
(
ls "${input_dir}"/*.fa > query_list.txt
fastANI -r reference.fa --ql query_list.txt --output "${output_dir}/fastani/fastani.tsv"
)  2>&1 | tee "${output_dir}/fastani/fastani.log"
rm query_list.txt
awk \
  '{alignment_percent = $4/$5*100} \
  {alignment_length = $4*3000} \
  {print $0 "\t" alignment_percent "\t" alignment_length}'\
  "${output_dir}/fastani/fastani.tsv" > "${output_dir}/fastani/fasani_with_aln.tsv"
awk 'BEGIN \
  {print "Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%Query_Aligned\tBasepairs_Query_Aligned"} \
  {print}' \
  "${output_dir}/fastani/fasani_with_aln.tsv" > "${output_dir}/fastani/fastani_summary.tsv"
rm "${output_dir}/fastani/fasani_with_aln.tsv"
echo "FastANI calculation completed."


# 3. Mash Distance Calculation
echo "Starting Mash distance calculation..."
(
mash dist reference.fa "${input_dir}"/*.fa > "${output_dir}/mash/mash.tsv"
) 2>&1 | tee "${output_dir}/mash/mash.log"
echo "Mash distance calculation completed."
awk 'BEGIN {print "Reference-ID\tQuery-ID\tMash-distance\tP-value\tMatching-hashes"} \
{print}' "${output_dir}/mash/mash.tsv" > ${output_dir}/mash/mash_summary.tsv


 # 4. CheckM : Classification and Quality Assessment
echo "Downloading CheckM data..."
mkdir -pv "${output_dir}/checkm/db"
mkdir -pv "${output_dir}/checkm/asm"
curl -o "${output_dir}/checkm/db/checkm_data_2015_01_16.tar.gz" https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
tar zxvf "${output_dir}/checkm/db/checkm_data_2015_01_16.tar.gz" -C "${output_dir}/checkm/db"
export CHECKM_DATA_PATH="${output_dir}/checkm/db/"

checkm data setRoot "${output_dir}/checkm/db/" 
checkm taxon_list | grep Neisseria
checkm taxon_set species "Neisseria gonorrhoeae" "${output_dir}/checkm/Ng.markers" 
markers_path="${output_dir}/checkm/Ng.markers"

echo "Starting CheckM analysis ..."
for file in "${input_dir}"/*.fa; do
    bin=$(basename "$file" | sed 's/_contigs\.fa$//')
    mkdir "${output_dir}/checkm/asm/${bin}"
    cp "$file" "${output_dir}/checkm/asm/${bin}/"
    checkm analyze "${markers_path}" "${output_dir}/checkm/asm/${bin}" \
    "${output_dir}/checkm/${bin}_analyze_output" -x fa 
done

(first_run=True
for folder in "${output_dir}/checkm"/*_analyze_output; do
    if [ "$first_run" = True ]; then
        checkm qa -o 1 "${markers_path}" "${folder}"  -q \
        >> "${output_dir}/checkm/checkm.tax.qa.output"
        first_run=False
    else
        checkm qa -o 1 "${markers_path}" "${folder}"  -q | tail -n 2\
        >> "${output_dir}/checkm/checkm.tax.qa.output"
    fi
done
)2>&1 | tee "${output_dir}/checkm/checkm.tax.qa.log"
echo "CheckM analysis completed."

# Organize files into one analyze_output folder
mkdir -pv "${output_dir}/checkm/analyze_output"
mv "${output_dir}/checkm"/*_analyze_output "${output_dir}/checkm/analyze_output"

# if you want separate qa files
# for folder in "${output_dir}/checkm"/*_analyze_output; do
#     checkm qa -f "${output_dir}/checkm/${bin}.tax.qa.output" \
#     -o 1 "${markers_parh}" "${output_dir}/checkm/${bin}_analyze_output"
# done


# 5. Kraken2 : Contig-by-contig Assessment
echo "Starting Kraken2 analysis..."
for file in "${input_dir}"/*.fa; do
    basename=$(basename "$file" | sed 's/_contigs//;s/.fa//')
    mkdir "${output_dir}/kraken2/${basename}"
    (
    kraken2 \
    --db "${kraken_db_path}" \
    --output "${output_dir}/kraken2/${basename}/${basename}.kraken2.output" \
    --report "${output_dir}/kraken2/${basename}/${basename}.kraken2.report" \
    $file
    )  2>&1 | tee "${output_dir}/kraken2/${basename}/${basename}.log" 
done
echo "Kraken2 analysis completed."

# compress the assembly files after the analysis
gzip "${input_dir}"/*
echo "Pipeline completed successfully! Results are saved in ${output_dir}"