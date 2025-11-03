# CheckM Genome Quality Assessment Results

This directory contains the results of genome quality assessment using CheckM. The command scripts, output files, and input genome assemblies are provided here.

## System Specifications

- **Cluster Environment**: PACE Cluster  
- **Modules**: Anaconda 3 (2023.03)
- **Quality of Service**: coc-ice
- **Node Type**: AMD CPU  
  - **Processor Model**: AMD EPYC 7513 32-Core Processor  
  - **Allocated Cores**: 16  
- **Memory**: 32 GB per node

## Tools Used
- **CheckM Genome Quality Assessment**: v1.2.3  
- **Conda**: for environment management

## Important Notes

- The **asm** folder contains the input genome assemblies (FASTA files).
- A species-specific marker set for *Neisseria gonorrhoeae* was generated using the `checkm taxon_set` command and saved as `Ng.markers`. This marker set was used for all subsequent analyses.
- 'cmds.sh': This script creates the required directory structure for CheckM, uncompresses the assembly files, downloads and extracts the CheckM database, and then sets up the environment by configuring the CHECKM_DATA_PATH variable and activating the Conda CheckM environment. Finally, it initializes CheckM by setting the database root and generating a taxon-specific marker set for Neisseria gonorrhoeae.
- 'script.py': This script runs checkM analysis and generates Quality Assessment result files. Run chmod +x script.py to make this script executable. Run ./script.py to execute
- Ensure that file paths in any command scripts (e.g., `cmds.sh`) match this directory layout.

## File Structure
```
checkm/
├── asm/
│   ├── B0993986_S01_L001_contigs.fa
│   ├── B0994486_S01_L001_contigs.fa
│   └── ...
├── checkm_output/
│   ├── B0993986_output/
│   │   ├── bins/
│   │   ├── bins_input/
│   │   ├── storage/
│   │   ├── checkm.B0993986.tax.qa.out
│   │   └── checkm.log
│   ├── B0994486_output/
│   │   ├── bins/
│   │   ├── bins_input/
│   │   ├── storage/
│   │   ├── checkm.B0994486.tax.qa.out
│   │   └── checkm.log
│   └── ...
├── Ng.markers
├── final_qa_results.txt
├── checkm_environment.yml
├── cmds.sh
├── script.py
└── README.md
