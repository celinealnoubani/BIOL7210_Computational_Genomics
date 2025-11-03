# Final Pipeline
This repository contains the script for genotyping & taxonomic classification & quality assessments pipeline along with the example that shows how to reproduce the results from our workflow. 

## Data Description
* `pipeline.sh` : This script allows you to reproduce the results from our workflow.
* `pipeline_env.yml` : This file shows information of the conda environment to develop and test the pipeline.

You can download assembly files that we used for the pipeline development from the `Final_Results/starting_data/assembly` folder. You can run the pipeline on the assembly files by passing a folder including them as an argument. (Each input assembly file should be compressed in a .gz format.) The reference genome used to calculate ANI scores of query sequences is from the `Final_Results/starting_data/reference` folder. You need not download this file as it will be downloaded while running the script.


## System Information
The following OS and hardware was used to develop the pipeline :

* Architecture : x86_64
* CPU : Apple M4
* Memory : 16 GB
* OS : macOS 15.3.1
* Kernel : 24.3.0

## Tools

* mlst : 2.23.0
* fastani : version 1.34
* mash : 2.3
* checkM : v1.2.3
* kraken2 : version 2.1.3


## Set up

### Environment Setup

* For Linux x86_64 and MacOS x86_64
```
conda create -n pipeline_env -y
conda activate pipeline_env
conda install -c bioconda -c conda-forge mlst fastani mash kraken2 checkm-genome -y 

```

* For MacOS ARM64 (using Rosetta)
  
For checkM to properly run, prodigal and hmer are required to be installed.

```
CONDA_SUBDIR=osx-64 conda create -n pipeline_env -y 
conda activate pipeline_env
conda install -c bioconda -c conda-forge mlst fastani mash kraken2 -y
conda install -c bioconda hmmer -y
conda install -c bioconda -c conda-forge prodigal -y
pip install checkm-genome
```

### Download Database for Kraken2

You can download kraken2 database before running the script using :

```
curl -o /your/desired/path/k2_standard_08gb_20241228.tar.gz https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20241228.tar.gz
```
Then, extract the contents :
```
tar -xvzf /your/desired/path/k2_standard_08gb_20241228.tar.gz -C /your/desired/path
```
You can also manually download the database [here](https://benlangmead.github.io/aws-indexes/k2). The pipeline used standard-8.

### Run the script

Make sure your script is executable and provide `<input_dir>` where contig files from the group 1 are located, `<output_dir>` where you want to put the results, and `<kraken_db_path>` where you downloaded the database.

```
chmod +x ./pipeline.sh
```
```
conda activate pipeline_env
```
```
./pipeline.sh <input_dir> <output_dir> <kraken_database_path>
```


### Expected Output 

The script will generate reference genome fasta file `reference.fa` and `output folder` that contains folders for each tool.
Each folder will contain outputs along with the log files. 
For mlst, fastani and mash, initial outputs are named as <tool_name>.tsv. `mlst_summary.tsv`, `fastani_summary.tsv`, `mash_summary.tsv` are final summary files with headers.
Checkm outputs `analyze_output/` that contains folders for each assembly file. Under checkm folder, you can also see the quality assessment results for the whole input files in `checkm.tax.qa.output`.
Kraken2 outputs a folder for each assembly input file which contains the report, output, and log file.

One example output looks like below.
Your `<input_dir>` is `ex_data` and contains two contig files (B0993986_S01_L001_contigs.fa.gz, B2541877_S01_L001_contigs.fa.gz).
`<output_dir>` and `<kraken_db_path>` are `output` and `database`.

Command used :
```
./pipeline.sh ./ex_data ./output ./database
```
File structure before running the script : 
```
.
├── database
│   ├── database100mers.kmer_distrib
│   ├── database150mers.kmer_distrib
│   ├── database200mers.kmer_distrib
│   ├── database250mers.kmer_distrib
│   ├── database300mers.kmer_distrib
│   ├── database50mers.kmer_distrib
│   ├── database75mers.kmer_distrib
│   ├── hash.k2d
│   ├── inspect.txt
│   ├── k2_standard_08gb_20241228.tar
│   ├── ktaxonomy.tsv
│   ├── library_report.tsv
│   ├── names.dmp
│   ├── nodes.dmp
│   ├── opts.k2d
│   ├── seqid2taxid.map
│   ├── taxo.k2d
│   └── unmapped_accessions.txt
├── ex_data
│   ├── B0993986_S01_L001_contigs.fa
│   └── B2541877_S01_L001_contigs.fa
└── pipeline.sh

```
File structure after running the script : 
```
.
├── database
│   ├── database100mers.kmer_distrib
│   ├── database150mers.kmer_distrib
│   ├── database200mers.kmer_distrib
│   ├── database250mers.kmer_distrib
│   ├── database300mers.kmer_distrib
│   ├── database50mers.kmer_distrib
│   ├── database75mers.kmer_distrib
│   ├── hash.k2d
│   ├── inspect.txt
│   ├── k2_standard_08gb_20241228.tar
│   ├── ktaxonomy.tsv
│   ├── library_report.tsv
│   ├── names.dmp
│   ├── nodes.dmp
│   ├── opts.k2d
│   ├── seqid2taxid.map
│   ├── taxo.k2d
│   └── unmapped_accessions.txt
├── ex_data
│   ├── B0993986_S01_L001_contigs.fa.gz
│   └── B2541877_S01_L001_contigs.fa.gz
├── output
│   ├── checkm
│   │   ├── Ng.markers
│   │   ├── analyze_output
│   │   │   ├── B0993986_S01_L001_analyze_output
│   │   │   │   ├── bins
│   │   │   │   │   └── B0993986_S01_L001_contigs
│   │   │   │   │       ├── genes.faa
│   │   │   │   │       ├── genes.gff
│   │   │   │   │       └── hmmer.analyze.txt
│   │   │   │   ├── checkm.log
│   │   │   │   └── storage
│   │   │   │       ├── aai_qa
│   │   │   │       │   └── B0993986_S01_L001_contigs
│   │   │   │       │       ├── PF02222.17.masked.faa
│   │   │   │       │       └── PF10004.4.masked.faa
│   │   │   │       ├── bin_stats.analyze.tsv
│   │   │   │       ├── bin_stats_ext.tsv
│   │   │   │       ├── checkm_hmm_info.pkl.gz
│   │   │   │       └── marker_gene_stats.tsv
│   │   │   └── B2541877_S01_L001_analyze_output
│   │   │       ├── bins
│   │   │       │   └── B2541877_S01_L001_contigs
│   │   │       │       ├── genes.faa
│   │   │       │       ├── genes.gff
│   │   │       │       └── hmmer.analyze.txt
│   │   │       ├── checkm.log
│   │   │       └── storage
│   │   │           ├── aai_qa
│   │   │           │   └── B2541877_S01_L001_contigs
│   │   │           │       ├── PF02222.17.masked.faa
│   │   │           │       └── PF10004.4.masked.faa
│   │   │           ├── bin_stats.analyze.tsv
│   │   │           ├── bin_stats_ext.tsv
│   │   │           ├── checkm_hmm_info.pkl.gz
│   │   │           └── marker_gene_stats.tsv
│   │   ├── asm
│   │   │   ├── B0993986_S01_L001
│   │   │   │   └── B0993986_S01_L001_contigs.fa
│   │   │   └── B2541877_S01_L001
│   │   │       └── B2541877_S01_L001_contigs.fa
│   │   ├── checkm.tax.qa.output
|   |   ├── checkm.tax.qa.log
│   │   └── db
│   │       ├── checkm_data_2015_01_16.tar.gz
│   │       ├── distributions
│   │       │   ├── cd_dist.txt
│   │       │   ├── gc_dist.txt
│   │       │   └── td_dist.txt
│   │       ├── genome_tree
│   │       │   ├── genome_tree.derep.txt
│   │       │   ├── genome_tree.metadata.tsv
│   │       │   ├── genome_tree.taxonomy.tsv
│   │       │   ├── genome_tree_full.refpkg
│   │       │   │   ├── CONTENTS.json
│   │       │   │   ├── genome_tree.fasta
│   │       │   │   ├── genome_tree.log
│   │       │   │   ├── genome_tree.tre
│   │       │   │   └── phylo_modelEcOyPk.json
│   │       │   ├── genome_tree_reduced.refpkg
│   │       │   │   ├── CONTENTS.json
│   │       │   │   ├── genome_tree.fasta
│   │       │   │   ├── genome_tree.log
│   │       │   │   ├── genome_tree.tre
│   │       │   │   └── phylo_modelJqWx6_.json
│   │       │   ├── missing_duplicate_genes_50.tsv
│   │       │   └── missing_duplicate_genes_97.tsv
│   │       ├── hmms
│   │       │   ├── checkm.hmm
│   │       │   ├── checkm.hmm.ssi
│   │       │   ├── phylo.hmm
│   │       │   └── phylo.hmm.ssi
│   │       ├── hmms_ssu
│   │       │   ├── SSU_archaea.hmm
│   │       │   ├── SSU_bacteria.hmm
│   │       │   ├── SSU_euk.hmm
│   │       │   └── createHMMs.py
│   │       ├── img
│   │       │   └── img_metadata.tsv
│   │       ├── pfam
│   │       │   ├── Pfam-A.hmm.dat
│   │       │   └── tigrfam2pfam.tsv
│   │       ├── selected_marker_sets.tsv
│   │       ├── taxon_marker_sets.tsv
│   │       └── test_data
│   │           └── 637000110.fna
│   ├── fastani
│   │   ├── fastani.log
│   │   ├── fastani.tsv
│   │   └── fastani_summary.tsv
│   ├── kraken2
│   │   ├── B0993986_S01_L001
│   │   │   ├── B0993986_S01_L001.kraken2.output
│   │   │   ├── B0993986_S01_L001.kraken2.report
│   │   │   └── B0993986_S01_L001.log
│   │   └── B2541877_S01_L001
│   │       ├── B2541877_S01_L001.kraken2.output
│   │       ├── B2541877_S01_L001.kraken2.report
│   │       └── B2541877_S01_L001.log
│   ├── mash
│   │   ├── mash.log
│   │   ├── mash.tsv
│   │   └── mash_summary.tsv
│   └── mlst
│       ├── mlst.log
│       └── mlst_summary.tsv
├── pipeline.sh
└── reference.fa
```
