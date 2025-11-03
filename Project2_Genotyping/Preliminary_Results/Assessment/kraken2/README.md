# Kraken2: Taxonomic Classification - Contig-by-Contig Analysis

## 📌 What is Kraken2?

Kraken2 is a widely used taxonomic classification tool designed for **high-throughput metagenomic sequence classification**.  
It uses an **exact k-mer matching algorithm** to classify sequences directly against a pre-built reference database.  
Kraken2 provides a **good balance between speed and accuracy**, making it highly suitable for large-scale contig-by-contig classification in metagenomics projects.

---

## 🔎 Key Features of Kraken2

- **Fast classification** using k-mer matching against pre-built reference databases.
- **Lightweight memory usage** through a compact hash table implementation.
- **Scalable to large datasets** with multi-threading support.
- **Direct classification to species and genus levels** from raw sequences.
- Supports classification at multiple taxonomic ranks:
    - Domain, Kingdom, Phylum, Class, Order, Family, Genus, Species
- Provides **both full classification report** and **per-sequence classification output**.

---

## 💾 Database Information

For our analysis, we used the **Kraken2 Standard Database** capped at **8 GB**, downloaded from the official Kraken2 resource:

- Database: `k2_standard_08gb_20241228`
- Release Date: December 28, 2024
- Size: ~7.5 GB (compressed)
- Suitable for machines with memory constraints.
- Contains comprehensive taxa covering bacteria, archaea, and viral sequences.
- Directly compatible with Kraken2 without additional preprocessing.

### Database Download Command
```bash
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_8gb_20241228.tar.gz
```


### Largest Dataset
```bash
kraken2 \
--db ./k2_standard_08gb_20241228 \
--threads 8 \
--output B1299860.kraken2.output \
--report B1299860.kraken2.report \
B1299860_S01_L001_contigs.fasta
```


### Smallest Dataset
```bash
kraken2 \
--db ./k2_standard_08gb_20241228 \
--threads 8 \
--output B1838859.kraken2.output \
--report B1838859.kraken2.report \
B1838859_S01_L001_contigs.fa
```


## 💻 Computational Environment

| Component | Specification |
|---|---|
| **OS** | macOS (ARM64 with Rosetta 2) |
| **Processor** | Apple M3 |
| **Cores/Threads** | 8 Cores  |
| **RAM** | 18 GB |
| **Conda Version** | 23.1.0 |
| **Kraken2 Version** | 2.1.3 (installed via bioconda) |

```



