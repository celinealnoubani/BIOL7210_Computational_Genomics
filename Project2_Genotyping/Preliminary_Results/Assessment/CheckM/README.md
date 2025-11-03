# CheckM Genome Quality Assessment Results

This directory contains the results of genome quality assessment using CheckM. The command scripts, output files, and input genome assemblies are provided here.

## System Specifications

- **Operating System**:  
  - **Cluster**: Hive HPC Cluster  
  - **Node**: Linux (Kernel 5.14.0-427.42.1.el9_4.x86_64)
- **System Architecture**: x86_64
- **Processor (CPU)**:
  - **Model**: Intel® Xeon® Gold 6226 CPU @ 2.70GHz  
  - **Cores**: 24 total (Dual-socket: 12 cores per socket, 1 thread per core)
- **Memory**: 187 GiB total (with ~176 GiB available)
- **Environment**:  
  - **Conda Environment**: A dedicated environment named `checkm` was created with CheckM v1.2.3 installed from conda-forge and bioconda.
- **Execution Context**:  
  - Commands were executed directly on the Hive cluster’s login node.

## Tools Used

- **CheckM Genome Quality Assessment**: v1.2.3  
- **Conda**: for environment management

## Important Notes

- The **asm** folder contains the input genome assemblies (FASTA files).
- The **db** folder stores the CheckM reference database and analysis outputs.
- A species-specific marker set for *Neisseria gonorrhoeae* was generated using the `checkm taxon_set` command and saved as `Ng.markers`. This marker set was used for all subsequent analyses.
- Ensure that file paths in any command scripts (e.g., `cmds.sh`) match this directory layout.

## File Structure
```
CheckM/
├── asm/
│   ├── small/
│   │   └── B1838859_S01_L001_contigs.fa
│   └── large/
│       └── B1299860_S01_L001_contigs.fa
├── db/
│   ├── analyze_small_output/
│   │   ├── bins/
│   │   │   └── B1838859_S01_L001_contigs/
│   │   │       ├── genes.faa (850K)
│   │   │       ├── genes.gff (484K)
│   │   │       └── hmmer.analyze.txt (2.6M)
│   │   ├── checkm.log (969 bytes)
│   │   └── storage/
│   │       ├── aai_qa/
│   │       │   └── B1838859_S01_L001_contigs/
│   │       │       ├── PF02222.17.masked.faa (427 bytes)
│   │       │       └── PF10004.4.masked.faa (407 bytes)
│   │       ├── bin_stats.analyze.tsv (433 bytes)
│   │       └── checkm_hmm_info.pkl.gz (100K)
│   ├── analyze_large_output/
│   │   ├── bins/
│   │   │   └── B1299860_S01_L001_contigs/
│   │   │       ├── genes.faa (847K)
│   │   │       ├── genes.gff (495K)
│   │   │       └── hmmer.analyze.txt (2.6M)
│   │   ├── checkm.log (969 bytes)
│   │   └── storage/
│   │       ├── aai_qa/
│   │       │   └── B1299860_S01_L001_contigs/
│   │       │       ├── PF02222.17.masked.faa (427 bytes)
│   │       │       └── PF10004.4.masked.faa (406 bytes)
│   │       ├── bin_stats.analyze.tsv (449 bytes)
│   │       └── checkm_hmm_info.pkl.gz (100K)
│   ├── Ng.markers
│   ├── checkm.large.tax.qa.out
│   └── checkm.small.tax.qa.out
└── cmds.sh
```
