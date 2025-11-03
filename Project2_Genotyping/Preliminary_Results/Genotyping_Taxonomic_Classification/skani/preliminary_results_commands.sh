# environment setup
conda create -n skani -y
conda activate skani
conda install -c bioconda skani -y
skani --version #skani 0.2.2

# set output directory
mkdir skani
cd data # where the data files are
ls 
# B1299860_S01_L001.fa B1838859_S01_L001.fa GCF_000006845.1_ASM684v1_genomic.fna.gz

# assembly data files and reference seq are in the current directory 
(/usr/bin/time -l skani dist -q *.fa \
-r GCF_000006845.1_ASM684v1_genomic.fna.gz \
-o ../skani/result.ts) 2>&1 | tee ../skani/skani.log

conda deactivate
