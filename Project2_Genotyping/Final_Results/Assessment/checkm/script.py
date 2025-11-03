#!/usr/bin/env bash

# This script runs checkM analysis and generates Quality Assessment result files. 
# Run chmod +x script.py to make this executable 
# Run ./script.py to run 

ASM_DIR="/home/hice1/calnoubani3/Documents/B3_Final/checkm/asm"
OUT_BASE="/home/hice1/calnoubani3/Documents/B3_Final/checkm/checkm_output"

# Ensure the base output directory exists
mkdir -p "$OUT_BASE"

for asm in "$ASM_DIR"/*.fa
do
    # Get the full filename without the .fa extension
    base=$(basename "$asm" .fa)  # e.g. "B0993986_S01_L001_contigs"
    
    # Extract the portion before the first underscore (e.g. "B0993986")
    short_name=$(echo "$base" | cut -d_ -f1)
    
    # Create a subdirectory for this assembly's output (e.g. "B0993986_output")
    outdir="${OUT_BASE}/${short_name}_output"
    mkdir -p "$outdir"

    # Create a temporary directory to hold bin files (input for CheckM)
    bins_input="${outdir}/bins_input"
    mkdir -p "$bins_input"
    
    # Copy the assembly file into bins_input with a standardized name
    cp "$asm" "${bins_input}/${short_name}.fa"

    # Run CheckM analyze on the temporary bins_input directory
    checkm analyze \
      --threads 16 \
      -x fa \
      Ng.markers \
      "$bins_input" \
      "$outdir"

    # Run CheckM QA on the output directory from analyze
    checkm qa \
      --file "$outdir/checkm.${short_name}.tax.qa.out" \
      --out_format 1 \
      --threads 16 \
      Ng.markers \
      "$outdir"
done
