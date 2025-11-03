# Final Results: Genotyping, Taxonomic Classification, and Quality Assessment

## 📂 Project Overview
This phase of the project focuses on performing **genotyping, taxonomic classification, and quality assessment** for all 34 assembly files/samples. The final pipeline covers a complete start-to-finish analysis, demonstrating the ability to process real sequencing data into meaningful biological insights.

## 🔗 Workflow Overview
### 1️⃣ Genotyping (MLST)
- **Tool:** MLST (Multi-Locus Sequence Typing)
- **Objective:** Assign sequence type using 7 conserved house-keeping genes.
- **Database:** pubMLST Neisseria scheme

### 2️⃣ Genus-level Taxonomic Classification
- **Tool:** MASH
- **Objective:** Determine genus using genome similarity to references.
- **Key Metrics:** MASH distance, Average Nucleotide Identity (ANI)

### 3️⃣ Species-level Taxonomic Classification
- **Tool:** FastANI 
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
