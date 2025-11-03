# Genotyping, Taxonomic Classification, and Quality Assessment for B3 Samples

## 📂 Project Overview
This project focuses on performing **genotyping, taxonomic classification, and quality assessment** for two datasets (largest and smallest). The workflow covers a complete start-to-finish analysis, demonstrating the ability to process real sequencing data into meaningful biological insights.

---

## 📊 Sample Information
| Sample | Dataset Type | Filename |
|---|---|---|
| B1299860 | Largest | B1299860_S01_L001_contigs.fasta |
| B1838859 | Smallest | B1838859_S01_L001_contigs.fa |
| Reference | Neisseria gonorrhoeae FA 1090 | GCF_000006845.1_ASM684v1_genomic.fna.gz |

---

## 🔗 Workflow Overview
### 1️⃣ Genotyping (MLST)
- **Tool:** MLST (Multi-Locus Sequence Typing)
- **Objective:** Assign sequence type using 7 conserved house-keeping genes.
- **Database:** pubMLST Neisseria scheme

### 2️⃣ Genus-level Taxonomic Classification
- **Tools:** MASH
- **Objective:** Determine genus using genome similarity to references.
- **Key Metrics:** MASH distance, Average Nucleotide Identity (ANI)

### 3️⃣ Species-level Taxonomic Classification
- **Tools:** FastANI, Skani, ANI Calculator
- **Objective:** Confirm species by whole genome comparison.
- **Key Metrics:** Average Nucleotide Identity (ANI) score (≥95% confirms species), Aligned Fraction

### 4️⃣ Whole Genome Quality Assessment
- **Tool:** CheckM
- **Objective:** Assess assembly completeness & contamination.
- **Database:** Neisseria gonorrhoeae lineage-specific markers

### 5️⃣ Fine-level Contig-by-Contig Taxonomic Classification
- **Tool:** Kraken2
- **Objective:** Taxonomic classification for each contig.
- **Database:** Kraken2 8GB Standard Database (2024-03)

---

### ⚙️ System Information
| Item | Specification |
|---|---|
| OS | macOS(ARM64) |
| CPU |  |
| Memory | 32 GB |
| Shell | zsh |
| Package Manager | Conda (Miniconda3) |

---
