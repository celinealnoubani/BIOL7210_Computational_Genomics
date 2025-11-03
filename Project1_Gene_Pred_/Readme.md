# 🧬 B2 Gene Prediction & Annotation  
🚀 *Comprehensive Analysis of Gene Prediction and Annotation Tools for Bacterial Genomes*

## 📌 Project Overview  
This repository contains preliminary results in which we evaluated various **gene prediction** and **annotation** tools to determine the most accurate and efficient approach for bacterial genome analysis. Additionally, it contains final results that include a final pipeline integrating the top gene prediction and annotation tools. The final results also contain the sub-workflows used to acheive identifying the best workflow (Prodigal-EggNog)

🔍 **Key Objectives:**  
- Compare different **Ab Initio** and **Homology-based** gene prediction tools  
- Assess **gene annotation tools** for functional insights  
- Develop and refine workflows for **bacterial genome annotation**  
- Identify the **optimal workflow** through comparative performance analysis  

---

## 🛠 Tools Used  

### **🔹 Gene Prediction (Ab Initio)**  
| Tool       | Description |
|------------|------------|
| **GeneMarkS-2** | Designed for small bacterial genomes (v 1.14_1.25) |
| **Glimmer** | Uses Markov models to predict ORFs |
| **Augustus** | HMM-based predictor, mainly for eukaryotes but adaptable to prokaryotes |
| **Prodigal** | Optimized for microbial genomes, fast and accurate (v2.6.3) |

### **🔹 Gene Prediction (Homology-Based)**  
| Tool       | Description |
|------------|------------|
| **BLAST** | Uses `tblastn` to compare proteins with our genome |
| **GeMoMa** | Identifies coding sequences based on homology (v1.9) |

### **🔹 Gene Prediction (16S rRNA)**  
| Tool       | Description |
|------------|------------|
| **Barrnap** | Uses `nhmmer` tool for HMM searching to identify rRNA genes (v0.9)|

### **🔹 Gene Annotation**  
| Tool       | Description |
|------------|------------|
| **EggNog-mapper** | Functional annotation based on orthologous groups (v2.1.12) |
| **InterPro** | Predicts protein functions using protein domain databases (v5.73-104.0) |

---

## 📁 Project Structure  
- 📂 Preliminary_results # Preliminary analysis and evaluations
- 📂 Final_results # Finalized workflows and performance analysis
- 📂 final_contigs # Genome assembly used for analysis (from group 1)
- 📂 presentation # Powerpoint slides
- 📜 README.md # This documentation

---

## 🧬 **Reference Genome & Dataset**  
- Genome assembly consists of contigs from an **unknown bacterial species**.  
- Initial BLASTN analysis identified it as belonging to **Neisseria gonorrhoeae**.  
- Two samples used for preliminary results:  
  - **Largest:**  B1299860_S01_L001  
  - **Smallest:** B1838859_S01_L001
- final_contigs contains all 34 samples used to run final results

---

## 🔬 **Workflows Evaluated**  

We refined the workflows based on our preliminary evaluations and tested four different pipelines combining the most promising gene prediction and annotation tools.

### **🔹 Gene Prediction - Gene Annotation Workflows**  
| Workflow Tools       | Description |
|------------|------------|
| **GeMoMa_InterPro** | GeMoMa (for homology-based gene prediction) w/ InterPro (for gene annotation) |
| **GeMoMa_EggNog** | GeMoMa (for homology-based gene prediction) w/ EggNog (for gene annotation) |
| **Prodigal_InterPro_Barrnap** | Prodigal (for abinitio-based gene prediction) w/ InterPro (for gene annotation) & Barrnap (for 16S rRNA) |
| **Prodigal_Eggnog** | Prodigal (for abinitio-based gene prediction) w/ EggNog (for gene annotation) |

---

## 🖥 **Standardized Runtime Environment**  

### **Preliminary Analysis Environment**  
- **Architecture:** x86_64 (AMD64)  
- **CPU:** Ryzen 9 7900X (12 Cores, 24 Threads)  
- **Memory:** 64 GB DDR5 CL30 6000 MT/S  
- **Operating System:** Ubuntu 22.04.3 LTS  

### **Final Workflow Analysis Environment**  
- **Cluster Environment**: PACE Cluster  
- **Modules**: Anaconda 3 (2023.03)  
- **Quality of Service**: coc-ice  
- **Node Type**: AMD CPU  
  - **Processor Model**: AMD EPYC 7513 32-Core Processor  
  - **Allocated Cores**: 16  
- **Memory**: 32 GB  

---

## 📊 **Results & Performance Analysis**  

### **🔬 CDS Prediction Results (Preliminary & Final)**  
| Tool        | Total CDS (Large) | Mean CDS Length (Large) | Total CDS (Small) | Mean CDS Length (Small) | Average CDS Count (across 34 runs) | Average Mean CDS Length (across 34 runs) |
|------------|------------------|------------------------|------------------|------------------------|------------------|------------------------|
| **GeneMark**  | 2317  | 658  | 2318  | 619  | - | - |
| **Glimmer**   | 2574  | 754  | 2550  | 911  | - | - |
| **Prodigal**  | 2085  | 852  | 2104  | 851  | 2147 | 839 |
| **Augustus**  | 1872  | 900  | 1891  | 898  | - | - |
| **BLAST**     | 2598  | 872  | 2702  | 865  | - | - |
| **GeMoMa**    | 2359  | 735  | 2397  | 746  | 2393 | 739 |
| **Ground Truth** | 2114 | ~940 | 2114 | ~940 | 2114 | ~940 |

### **🔬 Gene Prediction Tools: Runtime, Memory, CPU Usage (Final Results)**  
| Metric        | GeMoMa | Prodigal |  
|------------|------------------|------------------------|
| **Avg. Runtime (sec)**  | 32.62  | 36.32  |
| **Avg. Memory Usage (kB)**  | 2760796.24  | 47254  |
| **Avg. CPU Usage (%)** | 335.03 | 99 |

### **🔬 Gene Annotation Tools: Gene Overlap w/ Reference Genome**
| EggNog | InterPro | 
|--------|----------|
|   0.753    |    0.686     |

### **🔬 Gene Annotation Tools: Runtime, Memory, CPU Usage (Final Results)**  
| Metric        | EggNog | InterPro |  
|------------|------------------|------------------------|
| **Avg. Runtime (sec)**  | 184.99  | 78.00  |
| **Avg. Memory Usage (kB)**  | 3725382.82  |  3066533.06 |
| **Avg. CPU Usage (%)** | 818.21 | 161.44 |
---

## 📜 Conclusion-Prodigal_EggNOG: Best workflow
Our preliminary analysis identified **GeMoMa** as the most effective **homology-based** prediction tool, and **Prodigal** as the most efficient **ab initio** tool. **EggNog** and **InterPro** both provided valuable functional insights for gene annotation. Therefore, the final integrated workflow combines these best tools to yield accurate and efficient bacterial genome annotation results. The best workflow we found was **Prodigal-EggNog** due to Prodigal having the closest number of CDS count and mean CDS length to the reference genome. Additionally, EggNog displayed the highest annotated gene overlap with the reference genome. 

🚀 *This repository provides all necessary scripts, results, and workflows for future research and comparative genomics projects!*
