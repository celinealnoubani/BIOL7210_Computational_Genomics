#!/usr/bin/env bash

# ----------------------------------------------------
# Define absolute paths for your project
# ----------------------------------------------------
PROJECT_DIR="/home/hice1/calnoubani3/Documents/B2_Final"
SCRATCH_DIR="/home/hice1/calnoubani3/scratch"
DATA_DIR="$PROJECT_DIR/data"
CONTIGS_DIR="$DATA_DIR/contigs"
REF_DIR="$PROJECT_DIR/data/reference"
RESULTS_DIR="$PROJECT_DIR/results"
GEMOMA_OUT_DIR="$RESULTS_DIR/gemoma"
INTERPRO_OUT_DIR="$RESULTS_DIR/interpro"
LOGS_DIR="$PROJECT_DIR/logs"
FINAL_REPORT_DIR="$PROJECT_DIR/final_report"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# Final TSV report file (single file for both tools)
FINAL_REPORT="$FINAL_REPORT_DIR/final_metrics.tsv"

# GeMoMa conda environment name
GEMOMA_ENV="gemoma_env"

# InterProScan installation directory (adjust if needed)
INTERPROSCAN_DIR="$SCRATCH_DIR/interproscan-5.73-104.0"
#Note: I had to upload my interproscan-5.73-104.0 folder to a scratch directory for storage

# Reference files
GENOME="$REF_DIR/GCF_000006845.1_ASM684v1_genomic.fna"
GFF="$REF_DIR/GCF_000006845.1_ASM684v1_genomic.gff"

# ----------------------------------------------------
# Create directories if not present
# ----------------------------------------------------
mkdir -p "$GEMOMA_OUT_DIR" "$INTERPRO_OUT_DIR" "$LOGS_DIR" "$FINAL_REPORT_DIR"

# ----------------------------------------------------
# Activate GeMoMa conda environment
# ----------------------------------------------------
source activate "$GEMOMA_ENV"

# ----------------------------------------------------
# Write header for the final TSV file
# ----------------------------------------------------
# Columns: Sample, Tool, Memory_kB, Run_time_sec, CPU_usage, CDS_count, Mean_CDS_Length, Annotated_Proteins
echo -e "Sample\tTool\tMemory_kB\tRun_time_sec\tCPU_usage\tCDS_count\tMean_CDS_Length\tAnnotated_Proteins" > "$FINAL_REPORT"

# ----------------------------------------------------
# Loop over each gzipped contigs file
# ----------------------------------------------------
for contig_file in "$CONTIGS_DIR"/*_contigs.fa.gz; do
    # Extract sample name from file (e.g. B0938850_S01_L001)
    filename=$(basename "$contig_file")
    sample_name="${filename%%_contigs.fa.gz}"
    echo "Processing sample: $sample_name"
    
    # Set up output directory for this sample and force-delete any existing outputs
    sample_gemoma_out="$GEMOMA_OUT_DIR/$sample_name"
    rm -rf "$sample_gemoma_out"
    mkdir -p "$sample_gemoma_out"
    
    # Unzip contigs to a temporary file (will be removed later)
    temp_contig_file="$CONTIGS_DIR/${sample_name}_contigs.fa"
    gunzip -c "$contig_file" > "$temp_contig_file"
    
    # ------------------------------------------------
    # Run GeMoMa 
    # ------------------------------------------------
    gemoma_time_log="$LOGS_DIR/${sample_name}_gemoma_time.log"
    /usr/bin/time -v GeMoMa GeMoMaPipeline \
       threads=4 \
       outdir="$sample_gemoma_out" \
       GeMoMa.Score=ReAlign \
       AnnotationFinalizer.r=NO \
       o=true \
       t="$temp_contig_file" \
       i=1 \
       a="$GFF" \
       g="$GENOME" 2> "$gemoma_time_log"
    
    # Rename GFF output for clarity if it exists
    if [ -f "$sample_gemoma_out/unfiltered_predictions_from_species_0.gff" ]; then
        mv "$sample_gemoma_out/unfiltered_predictions_from_species_0.gff" \
           "$sample_gemoma_out/${sample_name}_predictions.gff"
    fi
    
    # Remove temporary contigs file
    rm -f "$temp_contig_file"
    
    # ------------------------------------------------
    # Extract and append GeMoMa metrics
    # ------------------------------------------------
    gemoma_memory=$(grep "Maximum resident set size" "$gemoma_time_log" | awk '{print $6}')
    gemoma_runtime=$(grep "Elapsed (wall clock) time" "$gemoma_time_log" | awk -F': ' '{print $2}')
    cpu_usage=$(grep "Percent of CPU this job got:" "$gemoma_time_log" | awk '{print $NF}')

    # Count CDS features from GeMoMa predictions if available
    if [ -f "$sample_gemoma_out/${sample_name}_predictions.gff" ]; then
        cds_count=$(grep -c "CDS" "$sample_gemoma_out/${sample_name}_predictions.gff")
        mean_cds_length=$(awk '$3=="CDS" { sum += ($5 - $4); count++ } END { if (count > 0) print sum/count; else print "NA" }' "$sample_gemoma_out/${sample_name}_predictions.gff")
    else
        cds_count=0
        mean_cds_length="NA"
    fi

    # Append GeMoMa row; for InterProScan metrics, mark Annotated_Proteins as NA
    echo -e "${sample_name}\tGeMoMa\t${gemoma_memory}\t${gemoma_runtime}\t${cpu_usage}\t${cds_count}\t${mean_cds_length}\tNA" >> "$FINAL_REPORT"

    # ------------------------------------------------
    # Run InterProScan on predicted_proteins.fasta (if it exists)
    # ------------------------------------------------
    #First make necessary files executable: 
    #chmod +x /home/hice1/calnoubani3/scratch/interproscan-5.73-104.0/interproscan.sh
    #chmod -R +x /home/hice1/calnoubani3/scratch/interproscan-5.73-104.0/bin

    #Additionally, ensure java is installed (java -version)

    predicted_proteins="$sample_gemoma_out/predicted_proteins.fasta"
    if [ -f "$predicted_proteins" ]; then
        # Clean the FASTA (remove asterisks)
        clean_proteins="$sample_gemoma_out/${sample_name}_predicted_proteins_clean.faa"
        sed 's/\*//g' "$predicted_proteins" > "$clean_proteins"
        
        interpro_out="$INTERPRO_OUT_DIR/${sample_name}_interpro.gff"
        interpro_time_log="$LOGS_DIR/${sample_name}_interpro_time.log"
        
        pushd "$INTERPROSCAN_DIR" > /dev/null
        /usr/bin/time -v ./interproscan.sh \
            -i "$clean_proteins" \
            -f gff3 \
            -o "$interpro_out" \
            -appl Pfam,SMART,TIGRFAM,ProSitePatterns,CDD,PRINTS,SUPERFAMILY \
            --goterms \
            --pathways \
            -cpu 8 2> "$interpro_time_log"
        popd > /dev/null
        
        # Extract InterProScan metrics 
        interpro_memory=$(grep "Maximum resident set size" "$interpro_time_log" | awk '{print $6}')
        interpro_runtime=$(grep "Elapsed (wall clock) time" "$interpro_time_log" | awk -F': ' '{print $2}')
        cpu_usage=$(grep "Percent of CPU this job got:" "$interpro_time_log" | awk '{print $NF}')

        # Count the number of unique annotated proteins
        if [ -f "$interpro_out" ]; then
            annotated_proteins=$(grep -v '^#' "$interpro_out" |        # Skip header lines
            grep polypeptide |                    # Only consider lines with polypeptide features
            awk -F'ID=' '{print $2}' |           # Split on "ID=" and print the second field
            cut -d';' -f1 |                       # Cut off the rest after the first semicolon
            sort | uniq | wc -l)
        else
            annotated_proteins=0
        fi
        
        # Append InterProScan row; for Gemoma metrics, mark CDS_count and Mean_CDS_length as NA
        echo -e "${sample_name}\tInterProScan\t${interpro_memory}\t${interpro_runtime}\t${cpu_usage}\tNA\tNA\t${annotated_proteins}" >> "$FINAL_REPORT"

    else
        echo "No predicted_proteins.fasta found for sample $sample_name; skipping InterProScan."
    fi

done

echo "Pipeline complete."
echo "Final metrics in: $FINAL_REPORT"

#compress interpro result files 
gzip /home/hice1/calnoubani3/Documents/B2_Final/results/interpro/*.gff


#Note: Remember to make this command script executable:
#chmod +x run_pipeline.sh
