# Genomic Annotation Pipeline: Prodigal, InterPro, and Barrnap

This repository contains the results of a comprehensive genomic annotation pipeline executed on the PACE cluster. The workflow integrates gene prediction using Prodigal, functional annotation with InterProScan, and rRNA identification with Barrnap. This repository includes the main pipeline script, output files, and performance metrics.

## System Specifications
- **Cluster Environment**: PACE Cluster  
- **Modules**: Anaconda 3 (2023.03)
- **Quality of Service**: coc-ice
- **Node Type**: AMD CPU  
  - **Processor Model**: AMD EPYC 7513 32-Core Processor  
  - **Allocated Cores**: 16  
- **Memory**: 32 GB

## Tools Used
- **Prodigal**: Version 2.6.3 (Gene prediction)
- **InterProScan**: Version 5.55-88.0 (Functional annotation)
- **Barrnap**: Version 0.9 (rRNA detection)
- **SeqKit**: Latest version (Sequence manipulation)

## Language Used
- **GNU Bash**: Version 5.0.18
- **Python**: Version 3.9 (conda environment)

## Important Notes
- The pipeline processes compressed FASTA files (*.fa.gz) and produces comprehensive annotation files in GFF format.
- InterProScan analysis uses multiple databases (Pfam, SMART, TIGRFAM, CDD, PRINTS, SUPERFAMILY) for thorough functional annotation.
- Performance metrics (runtime, memory usage, and CPU utilization) for all tools are recorded in the metrics directory.
- Protein sequences are automatically cleaned to remove asterisk characters that would cause InterProScan to fail.
- Final annotation files combine gene predictions, functional annotations, and rRNA features into a single GFF file.

## File Structure
- **Prodigal/**:
	Contains output files from Prodigal gene prediction: 
	- `*.gff`: Gene prediction annotations in GFF format 
	- `*.faa`: Predicted protein sequences in FASTA format 
	- `*.fna`: Nucleotide sequences of predicted genes 
	- `*_clean.faa`: Cleaned protein sequences (asterisks removed)

- **Barrnap/**:
Contains output files from Barrnap rRNA detection: 
	- `*_rRNA.gff`: GFF annotation file with identified rRNA features 
	- `*_rRNA.fasta`: FASTA file containing the rRNA sequences 

- **InterPro/**:
Contains output files from InterProScan functional annotation: 
	- `*_clean.faa.tsv`: Tab-separated annotation results 
	- `*_clean.faa.gff3`: GFF3 format annotations 

- **Results/**:
Contains the final combined annotation files: 
	- `*_annotated.gff.gz`: Compressed GFF file combining Prodigal, InterProScan, and Barrnap results

- **Logs/**:
Contains detailed log files for each tool and sample: 
	- `prodigal_*.log`: Standard output from Prodigal 
	- `barrnap_*.log`: Standard output from Barrnap 
	- `interpro_*.log`: Standard output from InterProScan 
	- `*_version.log`: Version information for each tool

- **Metrics/**:
Contains performance metrics for each tool and sample: 
	- `prodigal_*.metrics`: Runtime, CPU, memory, and feature count for Prodigal 
	- `barrnap_*.metrics`: Runtime, CPU, memory, and feature count for Barrnap 
	- `interpro_*.metrics- `: Runtime, CPU, memory, and feature count for InterProScan

- **TempFiles/**:
Contains temporary uncompressed FASTA files used during processing

- **tool_comparison.tsv**:
A consolidated TSV file that summarizes performance metrics and output statistics for all tools:
	- `Sample name`
	- `Tool name` (Prodigal, Barrnap, or InterProScan) 
	- `Runtime` in seconds 
	- `CPU usage` percentage 
	- `Memory usage` in KB 
	- `CDS count` (for Prodigal) 
	- `16S rRNA count` (for Barrnap) 
	- `InterPro domain counts` (for InterProScan) 
	- `Detailed domain breakdown` by database (for InterProScan)

- **prodigal_mean_cds_length.tsv**:
A TSV file containing the mean CDS length for each sample processed by Prodigal.

- **pipeline.sh**:
The main pipeline script that executes the entire workflow.

## Pipeline Overview
1. **Prodigal**: Performs gene prediction on bacterial genomes
- Input: Compressed contig FASTA files (*.fa.gz)
- Output: Gene models (GFF), protein sequences (FAA), and nucleotide sequences (FNA)
- Parameters: Meta mode for metagenome/draft genomes

2. **Barrnap**: Identifies ribosomal RNA features
- Input: Compressed contig FASTA files (*.fa.gz)
- Output: rRNA annotations (GFF) and sequences (FASTA)
- Parameters: Bacterial kingdom, multi-threading

3. **InterProScan**: Provides functional annotation of predicted proteins
- Input: Cleaned protein sequences from Prodigal
- Output: Functional annotations including protein domains and GO terms
- Parameters: Multiple annotation databases (Pfam, SMART, TIGRFAM, CDD, PRINTS, SUPERFAMILY)

4. **Integration**: Combines all annotations into a single GFF file
- Input: Prodigal GFF, InterProScan GFF3, and Barrnap GFF
- Output: Comprehensive annotation file in GFF format

## Running the Pipeline
The pipeline can be executed using SLURM on a cluster:
```bash
chmod +x pipeline.sh
sbatch -t 180 --cpus-per-task=16 --mem=16G ./pipeline.sh
```
The script will:
1. Set up a conda environment with all required tools
2. Process all contig files in the input directory
3. Generate gene predictions, rRNA annotations, and functional annotations
4. Combine all results into comprehensive GFF files
5. Generate performance metrics and summary statistics

## Performance Metrics
Performance metrics are collected for each tool and sample, including:
1. Runtime in seconds
2. CPU usage percentage
3. Memory usage in KB
4. Feature counts (CDS, rRNA, protein domains)
These metrics are summarized in the `tool_comparison.tsv` file for easy comparison and analysis.

## Final Output Files
The pipeline produces standardized annotation files in the Results directory:
`*_annotated.gff.gz`: Compressed GFF file containing all annotations from Prodigal, InterProScan, and Barrnap.
Additionally, the mean CDS length for each sample is available in `prodigal_mean_cds_length.tsv`.
