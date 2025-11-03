#ran on mac_arm64
conda create -n group3
conda activate group3
conda install mash
brew install brewsci/bio/mlst #ran into issues conda installing mlst but this works for my arm64 mac

mash dist B1299860_S01_L001_contigs.fa GCF_000006845.1_ASM684v1_genomic.fna #calculate mash distance for largest assembly

mash dist B1838859_S01_L001_contigs.fa GCF_000006845.1_ASM684v1_genomic.fna #calculate mash distance for smallest assembly

mlst B1838859_S01_L001_contigs.fa > B1838859_S01_L001_Summary.tsv # genotype smallest assembly with mlst

mlst B1299860_S01_L001_contigs.fa > B1299860_S01_L001_Summary.tsv #genotype largest assembly with mlst
