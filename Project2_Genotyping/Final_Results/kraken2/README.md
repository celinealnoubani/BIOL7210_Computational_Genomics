# 🧬 Kraken2-based Metagenomic Analysis Pipeline

> B3 Final Works 
> Description: Full automated pipeline for genotyping, taxonomic classification, and visualization using Kraken2 and Krona.

---

## 📁 Project Structure

```bash
.
├── final_contigs/                 # Input contig files (*.fa or *.fa.gz)
├── kraken_db/                     # Kraken2 database
├── kraken_output/                 # Kraken2 reports and outputs
├── parsed_reports/                # Parsed TSV reports for easier analysis
├── krona_html/                    # Krona interactive visualization HTML files
├── strain_summary/                # Top 3 strain-level summary per sample
├── top3_strains.tsv              # Summary of top 3 strains across samples
├── top3_strains_barplot2.png     # Visualization of top 3 strain abundance
├── cmds.sh                        # Main shell script (run this)
└── vis_top3_strains.py           # Python script for visualization

## 🧪 Requirements

### ✅ Install via Conda

```bash
CONDA_SUBDIR=osx-64 conda create -n kraken2 -y
conda activate kraken2
conda install -c bioconda -c conda-forge kraken2 krona pandas matplotlib seaborn -y
```


## 🧠 Workflow Overview

### 1. 🔍 Kraken2 Classification

For each sample:
- `kraken2` is run on the contig file

Generates:
- `*.kraken2.report`: Full taxonomic classification report
- `*.kraken2.output`: Per-contig classification output

---

### 2. 📄 Parse Kraken2 Reports

- Converts `.report` files into clean `.parsed.tsv`
- Human-readable and tab-delimited

**Columns:**
- `Percentage`
- `FragmentsCovered`
- `FragmentsAssigned`
- `Rank`
- `TaxID`
- `Name`

---

### 3. 🌐 Krona HTML Visualization

- Converts `.kraken2.output` → `.krona.input`
- `ktImportTaxonomy` creates interactive HTML (`*.krona.html`)

**Enables:**
- Taxonomic tree navigation  
- Count visualization  
- Taxonomic ranks and paths  

---

### 4. 🧬 Strain-Level Summary (Top 3)

From each `.report` file:

**Extracts:**
- Top 1 Species (Rank `S`)
- Top 2 Strains (Rank `S1`)

Saves results to:

```text
strain_summary/top3_strains.tsv
```




## 📦 Kraken2 Database Setup

> Only required once before running the workflow.

```bash
mkdir -p kraken_db
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_8gb_20241228.tar.gz
tar -xvzf k2_standard_8gb_20241228.tar.gz -C kraken_db/
```
## ✅ Note:
This is the smallest (8GB) version of the Kraken2 database.
Larger databases (e.g., 16GB or full standard DB) offer improved classification accuracy, especially for rare or low-abundance taxa, but they require significantly more memory and storage.

## 🧪 Challenges of Kraken2
`.report` files can be hard to interpret directly

Requires extra steps for visualization

DB size trade-off:

Small DBs (like 8GB used here) are fast but may miss rare taxa

Large DBs improve accuracy but are memory-intensive

