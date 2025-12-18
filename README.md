# BIOL 7210 - Computational Genomics

**Georgia Institute of Technology**

## Overview

This repository contains coursework for Computational Genomics, covering bioinformatics tools and pipelines for microbial genomics analysis. The course provides hands-on experience with genome assembly, gene prediction, annotation, genotyping, taxonomic classification, and comparative genomics.

## Course Structure

| Module | Topics | Key Tools |
|--------|--------|-----------|
| [Software Management](./Software_Management_Exercise) | Conda environments, package management | Conda, Mamba, miniforge |
| [Read Cleaning & Assembly](./Read_Sequence_Cleaning_&_Genome_Assembly_Exercise) | Quality control, genome assembly | FastQC, Trimmomatic, SPAdes, SKESA |
| [Gene Prediction & Annotation](./Gene_Prediction_&_Annotation_Exercise) | Gene calling, functional annotation | Prodigal, barrnap, InterPro, EggNOG |
| [Genotyping & QA](./Genotyping_Taxonomic_&_QA_Exercise) | Taxonomic ID, quality assessment | FastANI, MLST, CheckM |
| [Comparative Genomics](./Comparative_Genomics_Exercise) | SNP analysis, phylogenetics | ParSNP, Snippy, BinDash |

---

## Exercises

### 1. Software Management Exercise
Introduction to conda environment management for bioinformatics workflows.

**Skills:**
- Creating and managing conda environments
- Installing packages from bioconda/conda-forge channels
- Exporting environment specifications (YAML files)
- Version control for reproducibility

**Tools:** Conda, miniforge, FastANI, fasten, pandas

---

### 2. Read Sequence Cleaning & Genome Assembly Exercise
End-to-end pipeline from raw sequencing data to assembled genome.

**Workflow:**
1. **Data Acquisition** - Fetch FastQ from NCBI SRA (`fasterq-dump`)
2. **Quality Assessment** - Evaluate read quality (`FastQC`)
3. **Read Cleaning** - Remove low-quality reads (`Trimmomatic`)
4. **Genome Assembly** - De novo assembly (`SPAdes`, `SKESA`)
5. **Post-processing** - Filter contigs by coverage/length

**Key Results:**
- SPAdes assembly: ~101 contigs
- SKESA assembly: ~28 contigs (more stringent)

---

### 3. Gene Prediction & Annotation Exercise
Identifying genes and assigning biological functions.

**Components:**
| Task | Tool | Description |
|------|------|-------------|
| Protein-coding genes | Prodigal | Ab initio gene prediction |
| rRNA genes | barrnap | Ribosomal RNA detection |
| Functional annotation | InterProScan | Domain/family assignment |
| Ortholog mapping | EggNOG-mapper | COG/KEGG pathway annotation |

---

### 4. Genotyping, Taxonomic Classification & QA Exercise
Species identification and assembly quality control.

**Analysis Types:**
- **ANI (Average Nucleotide Identity)** - Species-level classification using FastANI
- **MLST (Multi-Locus Sequence Typing)** - Strain typing
- **Quality Assessment** - Completeness and contamination checks with CheckM

---

### 5. Comparative Genomics Exercise
Outbreak analysis through genomic comparisons.

**Methods:**
| Analysis | Tool | Application |
|----------|------|-------------|
| Core genome SNPs | ParSNP | Rapid phylogenetic tree construction |
| Variant calling | Snippy | Reference-based SNP detection |
| Genome sketching | BinDash | Fast distance estimation |

**Application:** Outbreak investigation and transmission tracking

---

## Projects

### Project 1: Gene Prediction & Annotation Pipeline
Comprehensive comparison of gene prediction and annotation tools.

**Gene Prediction Tools Evaluated:**
- Ab initio: Prodigal, Glimmer, GeneMark
- Homology-based: GeMoMa, Augustus

**Annotation Tools Evaluated:**
- EggNOG-mapper
- InterProScan

**Key Findings:**
- **Best Ab Initio Predictor:** Prodigal - highest gene detection sensitivity
- **Best Homology-Based:** GeMoMa - accurate with reference genomes
- **Best Annotation:** EggNOG-mapper - comprehensive functional coverage
- **Recommended Workflow:** Prodigal + EggNOG-mapper for bacterial genomes

---

### Project 2: Genotyping, Taxonomic Classification & QA
Large-scale genotyping pipeline for 34 bacterial assembly samples.

**Pipeline Components:**
| Stage | Tools | Purpose |
|-------|-------|---------|
| Genotyping | MLST | Sequence type assignment |
| Taxonomic ID | FastANI, skani, Mash | Species classification |
| Quality Control | CheckM | Completeness/contamination |
| Visualization | Kraken2 + Krona | Taxonomic composition |

**Tools Used:**
- MLST v2.23.0
- FastANI v1.34
- skani v0.2.2
- Mash v2.3
- CheckM v1.2.3
- Kraken2 v2.1.3

---

## Technical Skills Demonstrated

### Bioinformatics Pipelines
- Raw data QC and preprocessing
- De novo genome assembly
- Gene prediction (prokaryotic)
- Functional annotation
- Taxonomic classification
- Phylogenetic analysis

### Computational Skills
- Linux command-line proficiency
- Conda environment management
- Batch processing of genomic data
- Reproducible workflow design

### Analysis Types
- Average Nucleotide Identity (ANI)
- Multi-Locus Sequence Typing (MLST)
- Core genome SNP analysis
- Outbreak epidemiology

---

## Repository Structure

```
BIOL7210_Computational_Genomics/
├── Software_Management_Exercise/           # Conda basics
├── Read_Sequence_Cleaning_&_Genome_Assembly_Exercise/  # Assembly pipeline
├── Gene_Prediction_&_Annotation_Exercise/  # Gene calling & annotation
├── Genotyping_Taxonomic_&_QA_Exercise/    # Species ID & QC
├── Comparative_Genomics_Exercise/          # SNP & phylogenetics
├── Github_Exercise/                        # Version control
├── Project1_Gene_Pred_/                    # Gene prediction comparison
├── Project2_Genotyping/                    # Large-scale genotyping
│   ├── Preliminary_Results/
│   ├── Final_Results/
│   └── Presentation/
└── README.md
```

---

## Key Concepts

- **Genome Assembly Quality** - N50, completeness, contamination metrics
- **Gene Prediction Strategies** - Ab initio vs. homology-based approaches
- **Taxonomic Resolution** - ANI thresholds for species delineation (95%)
- **Outbreak Investigation** - Using SNP distances for transmission inference
- **Reproducibility** - Conda environments and version tracking

---

## Technologies Used

- **Assembly:** SPAdes, SKESA
- **Gene Prediction:** Prodigal, GeMoMa, Glimmer, GeneMark, Augustus
- **Annotation:** EggNOG-mapper, InterProScan, barrnap
- **Taxonomic ID:** FastANI, skani, MLST, Kraken2
- **Quality Control:** FastQC, Trimmomatic, CheckM
- **Comparative Genomics:** ParSNP, Snippy, BinDash
- **Visualization:** Krona

---


