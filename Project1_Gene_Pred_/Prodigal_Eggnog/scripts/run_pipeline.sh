#!/usr/bin/env bash

# ----------------------------------------------------
# Define absolute paths for your project
# ----------------------------------------------------
PROJECT_DIR="/home/hice1/sfang86/Documents/prodigal_eggnog/"
SCRATCH_DIR="/home/hice1/sfang86/scratch"
DATA_DIR="$PROJECT_DIR/data"
CONTIGS_DIR="$DATA_DIR/contigs"
RESULTS_DIR="$PROJECT_DIR/results"
PRODIGAL_OUT_DIR="$RESULTS_DIR/prodigal"  # Changed from GEMOMA_OUT_DIR
EGGNOG_OUT_DIR="$RESULTS_DIR/eggnog"
FINAL_OUT_DIR="$RESULTS_DIR/final_annotations"  # New directory for final annotation files
LOGS_DIR="$PROJECT_DIR/logs"
FINAL_REPORT_DIR="$PROJECT_DIR/final_report"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# Final TSV report file (single file for both tools)
FINAL_REPORT="$FINAL_REPORT_DIR/final_metrics.tsv"

# Conda environment names
PRODIGAL_ENV="prodigal_env"  # Changed from GEMOMA_ENV
EGGNOG_ENV="eggnog_env"

# EggNOG database directory - update this path to where your eggNOG database is stored
EGGNOG_DB_DIR="$SCRATCH_DIR/eggnog_db"


# ----------------------------------------------------
# Create directories if not present
# ----------------------------------------------------
mkdir -p "$PRODIGAL_OUT_DIR" "$EGGNOG_OUT_DIR" "$LOGS_DIR" "$FINAL_REPORT_DIR" "$FINAL_OUT_DIR"

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
    sample_prodigal_out="$PRODIGAL_OUT_DIR/$sample_name"
    rm -rf "$sample_prodigal_out"
    mkdir -p "$sample_prodigal_out"
    
    # Unzip contigs to a temporary file (will be removed later)
    temp_contig_file="$CONTIGS_DIR/${sample_name}_contigs.fa"
    gunzip -c "$contig_file" > "$temp_contig_file"
    
    # ------------------------------------------------
    # Run Prodigal (always re-run)
    # ------------------------------------------------
    # Activate Prodigal conda environment
    echo "Activating Prodigal environment: $PRODIGAL_ENV"
    source activate "$PRODIGAL_ENV"
    
    prodigal_time_log="$LOGS_DIR/${sample_name}_prodigal_time.log"
    # Run Prodigal for gene prediction
    /usr/bin/time -v prodigal \
        -i "$temp_contig_file" \
        -o "$sample_prodigal_out/${sample_name}_prodigal.gff" \
        -a "$sample_prodigal_out/predicted_proteins.fasta" \
        -d "$sample_prodigal_out/predicted_genes.fna" \
        -p meta \
        -f gff 2> "$prodigal_time_log"
    
    # Rename GFF output for clarity if it exists
    prodigal_gff_output="$sample_prodigal_out/${sample_name}_Prodigal.gff"
    if [ -f "$sample_prodigal_out/${sample_name}_prodigal.gff" ]; then
        cp "$sample_prodigal_out/${sample_name}_prodigal.gff" "$prodigal_gff_output"
        # Also copy to the final output directory with the proper naming convention
        cp "$sample_prodigal_out/${sample_name}_prodigal.gff" "$FINAL_OUT_DIR/${sample_name}_Prodigal.gff"
    fi
    
    # Remove temporary contigs file
    rm -f "$temp_contig_file"
    
    # ------------------------------------------------
    # Extract and append Prodigal metrics
    # ------------------------------------------------
    prodigal_memory=$(grep "Maximum resident set size" "$prodigal_time_log" | awk '{print $6}')
    prodigal_runtime=$(grep "Elapsed (wall clock) time" "$prodigal_time_log" | awk -F': ' '{print $2}')
    prodigal_cpu=$(grep "Percent of CPU this job got" "$prodigal_time_log" | awk '{print $7}' | sed 's/%//')
    
    # Count CDS features from Prodigal predictions if available
    if [ -f "$prodigal_gff_output" ]; then
        cds_count=$(grep -c "CDS" "$prodigal_gff_output")
    else
        cds_count=0
    fi
    # Append Prodigal row; for EggNOG metrics, mark Annotated_Proteins as NA
    echo -e "${sample_name}\tProdigal\t${prodigal_memory}\t${prodigal_runtime}\t${prodigal_cpu}\t${cds_count}\tNA" >> "$FINAL_REPORT"
    
    # Clean protein sequences (remove asterisks) and fix sequence IDs for EggNOG-mapper
    if [ -f "$sample_prodigal_out/predicted_proteins.fasta" ]; then
        # First create a clean version without asterisks
        sed 's/\*//g' "$sample_prodigal_out/predicted_proteins.fasta" > "$sample_prodigal_out/${sample_name}_temp_clean.faa"
        
        # Then modify the sequence headers to match the GFF ID format
        # Change from ">contigs_1_1 # 427 # 1461 # 1 # ID=1_1;..." to ">1_1 # 427 # 1461 # 1 # ID=1_1;..."
        sed -E 's/^>contigs_([0-9]+_[0-9]+) (.*ID=)([0-9]+_[0-9]+)(;.*)/>\3 \2\3\4/' "$sample_prodigal_out/${sample_name}_temp_clean.faa" > "$sample_prodigal_out/${sample_name}_predicted_proteins_clean.faa"
        
        # Remove temporary file
        rm -f "$sample_prodigal_out/${sample_name}_temp_clean.faa"
        
        echo "Modified sequence IDs to match GFF file format"
    fi
    
    # ------------------------------------------------
    # Run EggNOG-mapper on predicted_proteins.fasta (if it exists)
    # ------------------------------------------------
    clean_proteins="$sample_prodigal_out/${sample_name}_predicted_proteins_clean.faa"
    if [ -f "$clean_proteins" ] && [ -f "$prodigal_gff_output" ]; then
        # Create output directory for EggNOG results
        sample_eggnog_out="$EGGNOG_OUT_DIR/$sample_name"
        mkdir -p "$sample_eggnog_out"
        
        # Deactivate Prodigal environment and activate EggNOG environment
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
            --decorate_gff "$prodigal_gff_output" \
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
            final_gff="$FINAL_OUT_DIR/${sample_name}_Prodigal_EggNOG.gff"
            cp "$decorated_gff" "$final_gff"
            echo "Created final annotation file: $final_gff"
            
            # Also create a GenBank format file if possible (using any available tool)
            # This is optional and depends on available tools in your environment
            if command -v gff2gbk.py &> /dev/null; then
                final_gbk="$FINAL_OUT_DIR/${sample_name}_Prodigal_EggNOG.gbk"
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
        
        # Deactivate EggNOG environment and reactivate Prodigal for next iteration
        conda deactivate
        source activate "$PRODIGAL_ENV"
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

# Add mean CDS length metric (borrowed from pipeline.sh)
echo -e "Sample\tMean_CDS_Length" > "$RESULTS_DIR/prodigal_mean_cds_length.tsv" 
for file in "$PRODIGAL_OUT_DIR"/*/*.gff; do 
    sample=$(basename "$file" .gff)
    mean_length=$(awk '$3=="CDS" {sum += $5-$4+1; count++} END {print (count>0 ? sum/count : 0)}' "$file")
    echo -e "$sample\t$mean_length" >> "$RESULTS_DIR/prodigal_mean_cds_length.tsv"
done

# Note: Remember to make this command script executable:
# chmod +x run_pipeline.sh