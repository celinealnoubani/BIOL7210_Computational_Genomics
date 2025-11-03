#!/usr/bin/env bash

# ----------------------------------------------------
# Define absolute paths for your project
# ----------------------------------------------------
PROJECT_DIR="/home/hice1/sfang86/Documents/B2_Final_gff_16"
SCRATCH_DIR="/home/hice1/sfang86/scratch"
DATA_DIR="$PROJECT_DIR/data"
CONTIGS_DIR="$DATA_DIR/contigs"
REF_DIR="$PROJECT_DIR/data/reference"
RESULTS_DIR="$PROJECT_DIR/results"
GEMOMA_OUT_DIR="$RESULTS_DIR/gemoma"
EGGNOG_OUT_DIR="$RESULTS_DIR/eggnog"
FINAL_OUT_DIR="$RESULTS_DIR/final_annotations"  # New directory for final annotation files
LOGS_DIR="$PROJECT_DIR/logs"
FINAL_REPORT_DIR="$PROJECT_DIR/final_report"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# Final TSV report file (single file for both tools)
FINAL_REPORT="$FINAL_REPORT_DIR/final_metrics.tsv"

# Conda environment names
GEMOMA_ENV="gemoma_env"
EGGNOG_ENV="eggnog_env"

# EggNOG database directory - update this path to where your eggNOG database is stored
EGGNOG_DB_DIR="$SCRATCH_DIR/eggnog_db"

# Reference files
GENOME="$REF_DIR/GCF_000006845.1_ASM684v1_genomic.fna"
GFF="$REF_DIR/GCF_000006845.1_ASM684v1_genomic.gff"

# ----------------------------------------------------
# Create directories if not present
# ----------------------------------------------------
mkdir -p "$GEMOMA_OUT_DIR" "$EGGNOG_OUT_DIR" "$LOGS_DIR" "$FINAL_REPORT_DIR" "$FINAL_OUT_DIR"

# ----------------------------------------------------
# Write header for the final TSV file
# ----------------------------------------------------
# Columns: Sample, Tool, Memory_kB, Run_time_sec, CDS_count, Annotated_Proteins
echo -e "Sample\tTool\tMemory_kB\tRun_time_sec\tCPU_Usage\tCDS_count\tAnnotated_Proteins" > "$FINAL_REPORT"

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
    # Run GeMoMa (always re-run)
    # ------------------------------------------------
    # Activate GeMoMa conda environment
    echo "Activating GeMoMa environment: $GEMOMA_ENV"
    source activate "$GEMOMA_ENV"
    
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
    gemoma_gff_output="$sample_gemoma_out/${sample_name}_GeMoMa.gff"
    if [ -f "$sample_gemoma_out/unfiltered_predictions_from_species_0.gff" ]; then
        cp "$sample_gemoma_out/unfiltered_predictions_from_species_0.gff" "$gemoma_gff_output"
        # Also copy to the final output directory with the proper naming convention
        cp "$sample_gemoma_out/unfiltered_predictions_from_species_0.gff" "$FINAL_OUT_DIR/${sample_name}_GeMoMa.gff"
    fi
    
    # Remove temporary contigs file
    rm -f "$temp_contig_file"
    
    # ------------------------------------------------
    # Extract and append GeMoMa metrics
    # ------------------------------------------------
    gemoma_memory=$(grep "Maximum resident set size" "$gemoma_time_log" | awk '{print $6}')
    gemoma_runtime=$(grep "Elapsed (wall clock) time" "$gemoma_time_log" | awk -F': ' '{print $2}')
    gemoma_cpu=$(grep "Percent of CPU this job got" "$gemoma_time_log" | awk '{print $7}' | sed 's/%//')
    
    # Count CDS features from GeMoMa predictions if available
    if [ -f "$gemoma_gff_output" ]; then
        cds_count=$(grep -c "CDS" "$gemoma_gff_output")
    else
        cds_count=0
    fi
    # Append GeMoMa row; for EggNOG metrics, mark Annotated_Proteins as NA
    echo -e "${sample_name}\tGeMoMa\t${gemoma_memory}\t${gemoma_runtime}\t${gemoma_cpu}\t${cds_count}\tNA" >> "$FINAL_REPORT"
    
    # ------------------------------------------------
    # Run EggNOG-mapper on predicted_proteins.fasta (if it exists)
    # ------------------------------------------------
    predicted_proteins="$sample_gemoma_out/predicted_proteins.fasta"
    if [ -f "$predicted_proteins" ] && [ -f "$gemoma_gff_output" ]; then
        # Clean the FASTA (remove asterisks that might be present as stop codons)
        clean_proteins="$sample_gemoma_out/${sample_name}_predicted_proteins_clean.faa"
        sed 's/\*//g' "$predicted_proteins" > "$clean_proteins"
        
        # Create output directory for EggNOG results
        sample_eggnog_out="$EGGNOG_OUT_DIR/$sample_name"
        mkdir -p "$sample_eggnog_out"
        
        # Deactivate GeMoMa environment and activate EggNOG environment
        conda deactivate
        echo "Activating EggNOG environment: $EGGNOG_ENV"
        source activate "$EGGNOG_ENV"
        
        eggnog_time_log="$LOGS_DIR/${sample_name}_eggnog_time.log"
        
        echo "Running EggNOG-mapper for sample $sample_name..."
        
        # Run EggNOG-mapper with the --decorate_gff parameter to get GFF output
        /usr/bin/time -v emapper.py \
            -i "$clean_proteins" \
            --output "$sample_name" \
            --output_dir "$sample_eggnog_out" \
            --data_dir "$EGGNOG_DB_DIR" \
            --cpu 16 \
            --tax_scope bacteria \
            --go_evidence all \
            --decorate_gff "$gemoma_gff_output" \
            --override 2> "$eggnog_time_log"
        
        # Rename annotation files for clarity
        if [ -f "$sample_eggnog_out/${sample_name}.emapper.annotations" ]; then
            mv "$sample_eggnog_out/${sample_name}.emapper.annotations" \
               "$sample_eggnog_out/${sample_name}.emapper.annotations.tsv"
        fi
        
        # Check if the decorated GFF file was created
        decorated_gff="$sample_eggnog_out/${sample_name}.emapper.decorated.gff"
        if [ -f "$decorated_gff" ]; then
            echo "EggNOG decorated GFF file created: $decorated_gff"
            
            # Copy to final output directory with the proper naming convention
            final_gff="$FINAL_OUT_DIR/${sample_name}_GeMoMa_EggNOG.gff"
            cp "$decorated_gff" "$final_gff"
            echo "Created final annotation file: $final_gff"
            
            # Also create a GenBank format file if possible (using any available tool)
            # This is optional and depends on available tools in your environment
            if command -v gff2gbk.py &> /dev/null; then
                final_gbk="$FINAL_OUT_DIR/${sample_name}_GeMoMa_EggNOG.gbk"
                gff2gbk.py -i "$final_gff" -f "$temp_contig_file" -o "$final_gbk"
                echo "Created GenBank format file: $final_gbk"
            else
                echo "gff2gbk.py not found. Skipping GenBank file creation."
            fi
        else
            echo "WARNING: EggNOG decorated GFF file was not created."
        fi
        
        eggnog_exit_status=$?
        if [ $eggnog_exit_status -ne 0 ]; then
            echo "ERROR: EggNOG-mapper failed with exit code $eggnog_exit_status. Check log: $eggnog_time_log"
        else
            echo "EggNOG-mapper completed successfully for sample $sample_name"
        fi
        
        # Extract EggNOG metrics
        eggnog_memory=$(grep "Maximum resident set size" "$eggnog_time_log" | awk '{print $6}')
        eggnog_runtime=$(grep "Elapsed (wall clock) time" "$eggnog_time_log" | awk -F': ' '{print $2}')
        eggnog_cpu=$(grep "Percent of CPU this job got" "$eggnog_time_log" | awk '{print $7}' | sed 's/%//')
        
        # Count the number of unique annotated proteins
        annotations_file="$sample_eggnog_out/${sample_name}.emapper.annotations.tsv"
        if [ -f "$annotations_file" ]; then
            annotated_proteins=$(grep -v "^#" "$annotations_file" | cut -f 1 | sort | uniq | wc -l)
            echo "Found $annotated_proteins annotated proteins in $annotations_file"
        else
            annotated_proteins=0
            echo "WARNING: No annotations file found at $annotations_file"
        fi
        
        # Append EggNOG row
        echo -e "${sample_name}\tEggNOG\t${eggnog_memory}\t${eggnog_runtime}\t${eggnog_cpu}\tNA\t${annotated_proteins}" >> "$FINAL_REPORT"
        
        # Deactivate EggNOG environment and reactivate GeMoMa for next iteration
        conda deactivate
        source activate "$GEMOMA_ENV"
    else
        echo "No predicted_proteins.fasta or GFF file found for sample $sample_name; skipping EggNOG-mapper."
    fi

done

# Deactivate conda environment at the end
conda deactivate

echo "Pipeline complete."
echo "Final metrics in: $FINAL_REPORT"
echo "Final annotation files in: $FINAL_OUT_DIR"

# Compress EggNOG result files
#find "$EGGNOG_OUT_DIR" -name "*.emapper.annotations.tsv" -exec gzip {} \;

# List all final annotation files
echo "Generated annotation files:"
ls -l "$FINAL_OUT_DIR"

# Note: Remember to make this command script executable:
# chmod +x run_pipeline.sh
