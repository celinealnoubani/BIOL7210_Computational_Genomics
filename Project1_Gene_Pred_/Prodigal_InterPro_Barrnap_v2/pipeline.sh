#!/bin/bash
# Genomic Annotation Workflow v2.0
# This pipeline integrates Prodigal gene prediction with InterPro annotation and Barrnap rRNA extraction

# ---------- Global Configuration ---------- 
CONTIG_DIR="$HOME/xyuan99/biol7210/github/B2/final_contigs"
WORK_DIR="$HOME/xyuan99/biol7210/github/B2/Final_results/Prodigal_InterPro_Barrnap_v2"
ENV_NAME="Prodigal_InterPro_Barrnap_v2"
THREADS=16
START_TIME=$(date +%s)

# ---------- Version Information ----------
echo "=== Software Versions ==="
echo "OS: $(uname -a)"
echo "Bash: $(bash --version | head -n1)"
echo "Python: $(python --version 2>&1)"

# ---------- Directory Initialization ----------
mkdir -p ${WORK_DIR}/{Prodigal,Barrnap,InterPro,Logs,TempFiles,Metrics,Results}

# ---------- Conda Environment Setup ----------
setup_conda_env() {
    echo "Setting up conda environment..."

    # init conda
    eval "$(conda shell.bash hook)"
    
    # Check if environment exists
    if conda info --envs | grep -q ${ENV_NAME}; then
        echo "Environment ${ENV_NAME} already exists, using directly"
    else
        echo "Creating new conda environment: ${ENV_NAME}"
        conda create -y -n ${ENV_NAME} python=3.9
        
        # Install required tools
        conda activate ${ENV_NAME}
        conda install -y -c bioconda prodigal=2.6.3
        conda install -y -c bioconda barrnap=0.9
        conda install -y -c bioconda interproscan=5.55-88.0
        conda install -y -c conda-forge gzip
        conda install -y -c bioconda seqkit
        conda deactivate
    fi
    
    # Activate environment
    echo "Activating conda environment: ${ENV_NAME}"
    eval "$(conda shell.bash hook)"
    conda activate ${ENV_NAME}
    
    # Verify installations
    echo "Verifying tool installations..."
    command -v prodigal >/dev/null 2>&1 || { echo >&2 "Error: Prodigal installation failed"; exit 1; }
    command -v barrnap >/dev/null 2>&1 || { echo >&2 "Error: Barrnap installation failed"; exit 1; }
    command -v interproscan.sh >/dev/null 2>&1 || { echo >&2 "Error: InterProScan installation failed"; exit 1; }
    command -v gzip >/dev/null 2>&1 || { echo >&2 "Error: gzip installation failed"; exit 1; }
    command -v seqkit >/dev/null 2>&1 || { echo >&2 "Error: seqkit installation failed"; exit 1; }
    
    # Log versions for reproducibility
    prodigal -v > ${WORK_DIR}/Logs/prodigal_version.log 2>&1
    barrnap --version > ${WORK_DIR}/Logs/barrnap_version.log 2>&1
    interproscan.sh -version > ${WORK_DIR}/Logs/interproscan_version.log 2>&1
    seqkit version > ${WORK_DIR}/Logs/seqkit_version.log 2>&1
    
    echo "All tools successfully installed and verified"
}

# ---------- Gene Prediction Module (Prodigal) ----------
run_prodigal() {
    local contig=$1
    local base=$(basename ${contig} .fa.gz)
    local temp_file="${WORK_DIR}/TempFiles/${base}.fa"
    local metrics_file="${WORK_DIR}/Metrics/prodigal_${base}.metrics"
    
    echo "[$(date +'%F %T')] Processing ${base} with Prodigal..."
    
    # Decompress contig file
    gzip -dc ${contig} > ${temp_file}
    
    # Run Prodigal for gene prediction
    /usr/bin/time -f "Time=%e\nCPU=%P\nMem=%M" -o ${metrics_file} \
    prodigal -i ${temp_file} \
        -o ${WORK_DIR}/Prodigal/${base}.gff \
        -a ${WORK_DIR}/Prodigal/${base}.faa \
        -d ${WORK_DIR}/Prodigal/${base}.fna \
        -p meta \
        -f gff > ${WORK_DIR}/Logs/prodigal_${base}.log 2>&1
    
    # Check if Prodigal ran successfully
    if [ $? -eq 0 ]; then
        # Count CDS features
        local cds_count=$(grep -c "CDS" ${WORK_DIR}/Prodigal/${base}.gff)
        echo "CDS_count=${cds_count}" >> ${metrics_file}
        
        # Clean protein sequences (remove asterisks) for InterProScan
        sed 's/\*//g' ${WORK_DIR}/Prodigal/${base}.faa > ${WORK_DIR}/Prodigal/${base}_clean.faa
        
        echo "[$(date +'%F %T')] Prodigal completed successfully for ${base}: ${cds_count} CDS features identified"
    else
        echo "[$(date +'%F %T')] ERROR: Prodigal failed for ${base}. Check logs for details."
        return 1
    fi
}

# ---------- rRNA Extraction Module (Barrnap) ----------
run_barrnap() {
    local contig=$1
    local base=$(basename ${contig} .fa.gz)
    local temp_file="${WORK_DIR}/TempFiles/${base}.fa"
    local metrics_file="${WORK_DIR}/Metrics/barrnap_${base}.metrics"
    
    echo "[$(date +'%F %T')] Processing ${base} with Barrnap..."
    
    # Ensure temp file exists
    if [ ! -f ${temp_file} ]; then
        gzip -dc ${contig} > ${temp_file}
    fi
    
    # Run Barrnap for rRNA extraction
    /usr/bin/time -f "Time=%e\nCPU=%P\nMem=%M" -o ${metrics_file} \
    barrnap --kingdom bac \
        --threads ${THREADS} \
        --outseq ${WORK_DIR}/Barrnap/${base}_rRNA.fasta \
        --quiet ${temp_file} > ${WORK_DIR}/Barrnap/${base}_rRNA.gff 2> ${WORK_DIR}/Logs/barrnap_${base}.log
    
    # Check if Barrnap ran successfully
    if [ $? -eq 0 ]; then
        # Count rRNA features
        local rrna_count=$(grep -c "Name=16S_rRNA" ${WORK_DIR}/Barrnap/${base}_rRNA.gff)
        echo "16S_rRNA_count=${rrna_count}" >> ${metrics_file}
        
        echo "[$(date +'%F %T')] Barrnap completed successfully for ${base}: ${rrna_count} 16S rRNA features identified"
    else
        echo "[$(date +'%F %T')] ERROR: Barrnap failed for ${base}. Check logs for details."
        return 1
    fi
}

# ---------- Gene Annotation Module (InterPro) ----------
run_interpro() {
    local faa=$1
    local base=$(basename ${faa} _clean.faa)
    local metrics_file="${WORK_DIR}/Metrics/interpro_${base}.metrics"
    
    echo "[$(date +'%F %T')] Processing ${base} with InterProScan..."
    
    # Run InterProScan for functional annotation
    /usr/bin/time -f "Time=%e\nCPU=%P\nMem=%M" -o ${metrics_file} \
    interproscan.sh -i ${faa} \
        -d ${WORK_DIR}/InterPro \
        -f TSV,GFF3 \
        -appl Pfam,SMART,TIGRFAM,CDD,PRINTS,SUPERFAMILY \
        -goterms \
        -pa > ${WORK_DIR}/Logs/interpro_${base}.log 2>&1
    
    # Check if InterProScan ran successfully
    if [ $? -eq 0 ]; then
        # Count annotation features for each database
        if [ -f "${WORK_DIR}/InterPro/${base}_clean.faa.tsv" ]; then
            # init variables with int
            pfam_count=0
            smart_count=0
            tigrfam_count=0
            cdd_count=0
            prints_count=0
            superfamily_count=0
            
            # count each domain
            if grep -q "Pfam" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv" 2>/dev/null; then
                pfam_count=$(grep -c "Pfam" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv")
            fi
            
            if grep -q "SMART" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv" 2>/dev/null; then
                smart_count=$(grep -c "SMART" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv")
            fi
            
            if grep -q "TIGRFAM" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv" 2>/dev/null; then
                tigrfam_count=$(grep -c "TIGRFAM" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv")
            fi
            
            if grep -q "CDD" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv" 2>/dev/null; then
                cdd_count=$(grep -c "CDD" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv")
            fi
            
            if grep -q "PRINTS" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv" 2>/dev/null; then
                prints_count=$(grep -c "PRINTS" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv")
            fi
            
            if grep -q "SUPERFAMILY" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv" 2>/dev/null; then
                superfamily_count=$(grep -c "SUPERFAMILY" "${WORK_DIR}/InterPro/${base}_clean.faa.tsv")
            fi
            
            # ensure all variables are int
            pfam_count=${pfam_count:-0}
            smart_count=${smart_count:-0}
            tigrfam_count=${tigrfam_count:-0}
            cdd_count=${cdd_count:-0}
            prints_count=${prints_count:-0}
            superfamily_count=${superfamily_count:-0}
            
            # count total
            total_domains=$((pfam_count + smart_count + tigrfam_count + cdd_count + prints_count + superfamily_count))
            
            # Record counts in metrics file
            echo "Pfam_domains=${pfam_count}" >> ${metrics_file}
            echo "SMART_domains=${smart_count}" >> ${metrics_file}
            echo "TIGRFAM_domains=${tigrfam_count}" >> ${metrics_file}
            echo "CDD_domains=${cdd_count}" >> ${metrics_file}
            echo "PRINTS_domains=${prints_count}" >> ${metrics_file}
            echo "SUPERFAMILY_domains=${superfamily_count}" >> ${metrics_file}
            echo "Total_domains=${total_domains}" >> ${metrics_file}
            
            echo "[$(date +'%F %T')] InterProScan completed successfully for ${base}: ${total_domains} total domains identified"
        else
            echo "No_domains=0" >> ${metrics_file}
            echo "Total_domains=0" >> ${metrics_file}
            echo "[$(date +'%F %T')] InterProScan completed but no TSV output found for ${base}"
        fi
    else
        echo "[$(date +'%F %T')] ERROR: InterProScan failed for ${base}. Check logs for details."
        return 1
    fi
}


# ---------- Generate Final Output Files ----------
generate_outputs() {
    local base=$1
    
    echo "[$(date +'%F %T')] Generating final output files for ${base}..."
    
    # Combine GFF files (gene predictions + annotations)
    if [ -f "${WORK_DIR}/Prodigal/${base}.gff" ] && [ -f "${WORK_DIR}/InterPro/${base}_clean.faa.gff3" ]; then
        # Create combined GFF file
        cat ${WORK_DIR}/Prodigal/${base}.gff > ${WORK_DIR}/Results/${base}_annotated.gff
        grep -v "^#" ${WORK_DIR}/InterPro/${base}_clean.faa.gff3 >> ${WORK_DIR}/Results/${base}_annotated.gff
        
        # Add Barrnap results if available
        if [ -f "${WORK_DIR}/Barrnap/${base}_rRNA.gff" ]; then
            grep -v "^#" ${WORK_DIR}/Barrnap/${base}_rRNA.gff >> ${WORK_DIR}/Results/${base}_annotated.gff
        fi
        
        # Compress final GFF
        gzip -f ${WORK_DIR}/Results/${base}_annotated.gff
        
        echo "[$(date +'%F %T')] Successfully created annotated GFF for ${base}"
    else
        echo "[$(date +'%F %T')] WARNING: Could not create annotated GFF for ${base} - missing input files"
    fi
}

# ---------- Generate Performance Metrics TSV ----------
generate_metrics_tsv() {
    echo "[$(date +'%F %T')] Generating performance metrics TSV..."
    
    # Create header for TSV file with new column structure
    echo -e "Sample\tTool\tRuntime(s)\tCPU(%)\tMemory(KB)\tCDS_count\t16S_rRNA_count\tInterPro_total_domains\tInterPro_details" > ${WORK_DIR}/tool_comparison.tsv
    
    # Get list of all unique samples
    samples=$(find ${WORK_DIR}/Metrics/ -name "*.metrics" | sed 's/.*\/\([^_]*\)_\(.*\)\.metrics/\2/' | sort -u)
    
    # Process each sample
    for sample in $samples; do
        # Prodigal metrics
        if [ -f "${WORK_DIR}/Metrics/prodigal_${sample}.metrics" ]; then
            runtime=$(grep "Time=" "${WORK_DIR}/Metrics/prodigal_${sample}.metrics" | cut -d= -f2 | cut -f1)
            cpu=$(grep "CPU=" "${WORK_DIR}/Metrics/prodigal_${sample}.metrics" | cut -d= -f2 | cut -f1 | sed 's/%//')
            memory=$(grep "Mem=" "${WORK_DIR}/Metrics/prodigal_${sample}.metrics" | cut -d= -f2)
            cds_count=$(grep "CDS_count=" "${WORK_DIR}/Metrics/prodigal_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            
            # Prodigal doesn't provide 16S rRNA or InterPro data
            echo -e "${sample}\tProdigal\t${runtime}\t${cpu}\t${memory}\t${cds_count}\tNA\tNA\tNA" >> ${WORK_DIR}/tool_comparison.tsv
        fi
        
        # Barrnap metrics
        if [ -f "${WORK_DIR}/Metrics/barrnap_${sample}.metrics" ]; then
            runtime=$(grep "Time=" "${WORK_DIR}/Metrics/barrnap_${sample}.metrics" | cut -d= -f2 | cut -f1)
            cpu=$(grep "CPU=" "${WORK_DIR}/Metrics/barrnap_${sample}.metrics" | cut -d= -f2 | cut -f1 | sed 's/%//')
            memory=$(grep "Mem=" "${WORK_DIR}/Metrics/barrnap_${sample}.metrics" | cut -d= -f2)
            rrna_count=$(grep "16S_rRNA_count=" "${WORK_DIR}/Metrics/barrnap_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            
            # Barrnap doesn't provide CDS or InterPro data
            echo -e "${sample}\tBarrnap\t${runtime}\t${cpu}\t${memory}\tNA\t${rrna_count}\tNA\tNA" >> ${WORK_DIR}/tool_comparison.tsv
        fi
        
        # InterPro metrics
        if [ -f "${WORK_DIR}/Metrics/interpro_${sample}.metrics" ]; then
            runtime=$(grep "Time=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 | cut -f1)
            cpu=$(grep "CPU=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 | cut -f1 | sed 's/%//')
            memory=$(grep "Mem=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2)

            # Get total domains if available
            if grep -q "Total_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics"; then
                total_domains=$(grep "Total_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2)
            else
                total_domains=0
            fi
            
            # Collect detailed domain counts
            pfam=$(grep "Pfam_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            smart=$(grep "SMART_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            tigrfam=$(grep "TIGRFAM_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            cdd=$(grep "CDD_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            prints=$(grep "PRINTS_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            superfamily=$(grep "SUPERFAMILY_domains=" "${WORK_DIR}/Metrics/interpro_${sample}.metrics" | cut -d= -f2 2>/dev/null || echo 0)
            
            # Format InterPro details
            interpro_details="Pfam:${pfam},SMART:${smart},TIGRFAM:${tigrfam},CDD:${cdd},PRINTS:${prints},SUPERFAMILY:${superfamily}"
            
            # InterPro doesn't provide CDS or 16S rRNA data
            echo -e "${sample}\tInterProScan\t${runtime}\t${cpu}\t${memory}\tNA\tNA\t${total_domains}\t${interpro_details}" >> ${WORK_DIR}/tool_comparison.tsv
        fi
    done
    
    # Add a summary row with total counts across all samples
    echo -e "\n[$(date +'%F %T')] Performance metrics saved to ${WORK_DIR}/tool_comparison.tsv"
}


# ---------- Cleanup Temporary Files ----------
cleanup() {
    echo "[$(date +'%F %T')] Cleaning up temporary files..."
    
    if [ -d "${WORK_DIR}/TempFiles" ]; then
        rm -rf ${WORK_DIR}/TempFiles/*.fa
        echo "[$(date +'%F %T')] Temporary files removed"
    fi
}

# ---------- Main Workflow ----------
main() {
    echo "[$(date +'%F %T')] ========== GENOMIC ANNOTATION WORKFLOW STARTING =========="
    
    # Setup conda environment
    setup_conda_env
    
    # Validate input directory
    if [ ! -d "${CONTIG_DIR}" ]; then
        echo "[$(date +'%F %T')] ERROR: Input directory ${CONTIG_DIR} does not exist"
        exit 1
    fi
    
    # Check for input files
    if [ ! "$(ls -A ${CONTIG_DIR}/*.fa.gz 2>/dev/null)" ]; then
        echo "[$(date +'%F %T')] ERROR: No .fa.gz files found in ${CONTIG_DIR}"
        echo "Please check file paths and formats"
        exit 1
    fi
    
    # Process each contig file
    for contig in ${CONTIG_DIR}/*.fa.gz; do
        if [ -f "$contig" ]; then
            base=$(basename ${contig} .fa.gz)
            echo "[$(date +'%F %T')] ===== Processing sample: ${base} ====="
            
            # Run gene prediction
            run_prodigal ${contig}
            
            # Run rRNA extraction
            run_barrnap ${contig}
            
            # Run gene annotation (using cleaned protein sequences)
            if [ -f "${WORK_DIR}/Prodigal/${base}_clean.faa" ]; then
                run_interpro ${WORK_DIR}/Prodigal/${base}_clean.faa
            else
                echo "[$(date +'%F %T')] WARNING: Clean protein file not found for ${base}, skipping annotation"
            fi
            
            # Generate final outputs
            generate_outputs ${base}
        fi
    done
    
    # Generate performance metrics TSV
    generate_metrics_tsv
    
    # Cleanup temporary files
    cleanup
    
    # Deactivate conda environment
    conda deactivate
    
    # Calculate total runtime
    END_TIME=$(date +%s)
    TOTAL_RUNTIME=$((END_TIME - START_TIME))
    HOURS=$((TOTAL_RUNTIME / 3600))
    MINUTES=$(( (TOTAL_RUNTIME % 3600) / 60 ))
    SECONDS=$((TOTAL_RUNTIME % 60))
    
    echo "[$(date +'%F %T')] ========== WORKFLOW COMPLETED =========="
    echo "Total runtime: ${HOURS}h ${MINUTES}m ${SECONDS}s"
    echo "Results available in: ${WORK_DIR}/Results"
    echo "Performance metrics: ${WORK_DIR}/tool_comparison.tsv"
}

# Execute main workflow
main

# add mean cds length metric
echo -e "Sample\tMean_CDS_Length" > prodigal_mean_cds_length.tsv && for file in Prodigal/*.gff; do sample=$(basename $file .gff); mean_length=$(awk '$3=="CDS" {sum += $5-$4+1; count++} END {print (count>0 ? sum/count : 0)}' $file); echo -e "$sample\t$mean_length" >> prodigal_mean_cds_length.tsv; done

# execute pipeline with slurm
# chmod +x run_pipeline.sh
# sbatch -t 180 --cpus-per-task=16 --mem=16G ./pipeline.sh