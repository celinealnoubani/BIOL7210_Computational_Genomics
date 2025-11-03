# 🧬 B2 Gene Prediction & Annotation (Final Results) 
🚀 *Comprehensive Analysis of Gene Prediction and Annotation Tools for Bacterial Genomes*

## 📌 Project Overview  
This repository contains the 4 workflows that we ran combining our top gene prediction and annotation tools from the preliminary results, as well as a final pipeline which integrates all tools. Additionally, it contains a final tsv with the combined metrics from all workflows.
We evaluated the various **gene prediction** and **annotation** workflows to identify the most accurate and efficient one for bacterial genome analysis.  

## 4 Workflows  

### **🔹 Gene Prediction - Gene Annotation Workflows**  
| Workflow Tools       | Description |
|------------|------------|
| **GeMoMa_InterPro** | GeMoMa (for homology-based gene prediction) w/ InterPro (for gene annotation) |
| **GeMoMa_EggNog** | GeMoMa (for homology-based gene prediction) w/ EggNog (for gene annotation) |
| **Prodigal_InterPro_Barrnap** | Prodigal (for abinitio-based gene prediction) w/ InterPro (for gene annotation) & Barrnap (for 16S rRNA)|
| **Prodigal_Eggnog** | Prodigal (for abinitio-based gene prediction) w/ EggNog (for gene annotation) |
---

## 🛠 Tools Used  

### **🔹 Gene Prediction (Ab Initio)**  
| Tool       | Description |
|------------|------------|
| **Prodigal** | Optimized for microbial genomes, fast and accurate (PRODIGAL v2.6.3 [February, 2016] |

### **🔹 Gene Prediction (Homology-Based)**  
| Tool       | Description |
|------------|------------|
| **GeMoMa** | Identifies coding sequences based on homology (version 1.9) |

### **🔹 Gene Prediction (16S rRNA)**
| Tool       | Description |
|------------|------------|
| **Barrnap** | Uses `nhmmer` tool for HMM searching to identify rRNA genes (version 0.9) |

### **🔹 Gene Annotation**  
| Tool       | Description |
|------------|------------|
| **EggNog-mapper** | Functional annotation based on orthologous groups (version 2.1.12) |
| **InterPro** | Predicts protein functions using protein domain databases (version 5.73-104.0) |

---

## 🖥 **Standardized Runtime Environment**
- **Cluster Environment**: PACE Cluster  
- **Modules**: Anaconda 3 (2023.03)
- **Quality of Service**: coc-ice
- **Node Type**: AMD CPU  
  - **Processor Model**: AMD EPYC 7513 32-Core Processor  
  - **Allocated Cores**: 16  
- **Memory**: 32 GB per node

---

## 📊 **Results & Performance Analysis**

### **🔬 CDS Prediction Results**  
| Tool        | Average CDS Count (across 34 runs) | Average Mean CDS Length (across 34 runs) | 
|------------|------------------|------------------------|
| **GeMoMa**  | 2393  | 739  |
| **Prodigal**  | 2147  | 839  |
| **Ground Truth** | 2114 | ~940 | 

### **🔬 Gene Prediction Tools: Runtime, Memory, CPU Usage Results**  
| Metric        | GeMoMa | Prodigal | 
|------------|------------------|------------------------|
| **Avg. Runtime (sec)**  | 32.62  | 36.32  |
| **Avg. Memory Usage (kB)**  | 2760796.24  | 47254  |
| **Avg. CPU Usage (%)** | 335.03 | 99 |



---

### 📑 Gene Annotation
We compared **EggNOG** and **InterPro** against a reference annotation dataset.

### Annotation Overlap

- **EggNOG** showed a higher annotation overlap with the reference compared to InterPro.
- **InterPro** demonstrated lower overlap in certain samples, likely due to stricter annotation criteria.

### Runtime, Memory, and CPU Usage Comparison

| Tool     | Avg. Runtime (s) | Avg. Memory Usage (kB) | Avg. CPU Usage (%) |
|----------|-----------------|------------------------|--------------------|
| **InterPro** | 78.00 | 3,066,533 | 161.44% |
| **EggNOG** | 184.99 | 3725382.82 | 818.21% |

- **EggNOG** was more computationally intensive but provided more comprehensive annotations.
- **InterPro** was relatively faster but had limited annotation coverage.

## 📊 Results & Performance Analysis

### 🟠 **Annotation Overlap - InterPro vs. Reference**
| **Category**              | **Count** |
|---------------------------|-----------|
| Genes uniquely annotated by **InterPro** | 734 |
| Genes uniquely annotated by **Reference** | 664 |
| **Overlapping genes** (InterPro & Reference) | 1450 |



### 🟠 **Annotation Overlap - Eggnog vs. Reference**
| **Category**              | **Count** |
|---------------------------|-----------|
| Genes uniquely annotated by **Eggnog** | 272 |
| Genes uniquely annotated by **Reference** | 522 |
| **Overlapping genes** (Eggnog & Reference) | 1592 |

📌 **Key Insight**:  
InterPro shares a significant portion of annotations with the reference dataset, but some discrepancies exist.  
While InterPro is a reliable annotation tool, it does not fully align with the reference.




```
