# Commands for Checkm

# Make a Checkm directory & navigate into it
mkdir checkm
cd checkm/
# Make an assembly directory along with a database directory for CheckM's reference data to go
mkdir asm
mkdir db
# Navigate into the asm directory and create a folder for the small assembly .fa file
cd asm
mkdir small
# Manually put small assembly file into small folder and uncompress the file 
gunzip B1838859_S01_L001_contigs.fa.gz
ls #output: 
# B1838859_S01_L001_contigs.fa
# Navigate back into the asm directory and create a folder for the large assembly .fa file
cd ..
mkdir large
# Manually put large assembly file into large folder and uncompress the file
gunzip B1299860_S01_L001_contigs.fa.gz
ls #output: 
# B1299860_S01_L001_contigs.fa
# Navigate back into db directory
cd ..
cd ..
cd db
# Retrieve CheckM data
curl -O https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
# Extract the CheckM data
tar zxvf checkm_data_2015_01_16.tar.gz
# Find out my home path 
$HOME
# -bash: /storage/home/hhive1/calnoubani3: Is a directory
# Append the export command to .bashrc to permanently set the CHECKM_DATA_PATH environment variable
echo 'export CHECKM_DATA_PATH=$HOME/data/checkm/db' >> ~/.bashrc
# Reload .bashrc so the new environment variable becomes available in the current session
source ~/.bashrc
# Verify that the CHECKM_DATA_PATH has been set correctly 
echo "${CHECKM_DATA_PATH}"
# /storage/home/hhive1/calnoubani3/data/checkm/db
# Load anaconda3 to be able to use conda 
module load anaconda3
# Create a new Conda environment named "checkm" and install the checkm-genome package from the conda-forge and bioconda channels
conda create -n checkm -c conda-forge -c bioconda checkm-genome -y
# Activate the Conda environment
conda activate checkm
# Check to make sure CheckM installed & get the version number 
conda list | grep checkm
# packages in environment at /storage/home/hhive1/calnoubani3/.conda/envs/checkm:
# checkm-genome             1.2.3              pyhdfd78af_1    bioconda
cd .. #navigate to checkm directory
# Set the CheckM database root to the db directory
checkm data setRoot db/
#[2025-02-27 17:10:38] INFO: CheckM v1.2.3
#[2025-02-27 17:10:38] INFO: checkm data setRoot db/
#[2025-02-27 17:10:38] INFO: CheckM data: /storage/home/hhive1/calnoubani3/data/checkm/db
#[2025-02-27 17:10:38] INFO: [CheckM - data] Check for database updates.
cd db #navigate to db directory 
# List the taxonomic groups available in the CheckM database and filter for those related to Neisseria
checkm taxon_list | grep Neisseria 
# order     Neisseriales                                            69           658              446
# family    Neisseriaceae                                           69           658              446
# genus     Neisseria                                               47           887              501
# species   Neisseria flavescens                                    2            1305             164
# species   Neisseria gonorrhoeae                                   14           1201             205
# species   Neisseria meningitidis                                  20           997              216

# Generate a taxon-specific marker set for the species "Neisseria gonorrhoeae" and save the marker set to a file called Ng.markers
checkm taxon_set species "Neisseria gonorrhoeae" Ng.markers                                                          
# [2025-02-27 17:37:13] INFO: CheckM v1.2.3
# [2025-02-27 17:37:13] INFO: checkm taxon_set species Neisseria gonorrhoeae Ng.markers
# [2025-02-27 17:37:13] INFO: CheckM data: /storage/home/hhive1/calnoubani3/data/checkm/db
# [2025-02-27 17:37:13] INFO: [CheckM - taxon_set] Generate taxonomic-specific marker set.
# [2025-02-27 17:37:17] INFO: Marker set for Neisseria gonorrhoeae contains 1201 marker genes arranged in 205 sets.
# [2025-02-27 17:37:17] INFO: Marker set inferred from 14 reference genomes.
# [2025-02-27 17:37:17] INFO: Marker set for Neisseria contains 887 marker genes arranged in 501 sets.
# [2025-02-27 17:37:17] INFO: Marker set inferred from 47 reference genomes.
# [2025-02-27 17:37:17] INFO: Marker set for Neisseriaceae contains 658 marker genes arranged in 446 sets.
# [2025-02-27 17:37:17] INFO: Marker set inferred from 69 reference genomes.
# [2025-02-27 17:37:17] INFO: Marker set for Neisseriales contains 658 marker genes arranged in 446 sets.
# [2025-02-27 17:37:17] INFO: Marker set inferred from 69 reference genomes.
# [2025-02-27 17:37:17] INFO: Marker set for Betaproteobacteria contains 387 marker genes arranged in 234 sets.
# [2025-02-27 17:37:17] INFO: Marker set inferred from 322 reference genomes.
# [2025-02-27 17:37:17] INFO: Marker set for Proteobacteria contains 182 marker genes arranged in 119 sets.
# [2025-02-27 17:37:17] INFO: Marker set inferred from 2343 reference genomes.
# [2025-02-27 17:37:17] INFO: Marker set for Bacteria contains 104 marker genes arranged in 58 sets.
# [2025-02-27 17:37:17] INFO: Marker set inferred from 5449 reference genomes.
# [2025-02-27 17:37:18] INFO: Marker set written to: Ng.markers
# [2025-02-27 17:37:18] INFO: { Current stage: 0:00:04.601 || Total: 0:00:04.601 }

# Run CheckM's analysis on the small assembly dataset:
# - Use 8 threads
# - Look for bin files with the ".fa" extension (-x fa)
# - Use the previously generated "Ng.markers" marker set
# - Input directory is the "small" assemblies folder
# - Output results are saved in "analyze_small_output"
checkm \
  analyze \
  --threads 8 -x fa \
  Ng.markers \
  /storage/home/hhive1/calnoubani3/data/checkm/asm/small/ \
  analyze_small_output

# Run CheckM's analysis on the large assembly dataset with the same parameters saving the output in "analyze_large_output"
checkm \
  analyze \
  --threads 8 -x fa \
  Ng.markers \
  /storage/home/hhive1/calnoubani3/data/checkm/asm/large/ \
  analyze_large_output

# Use the "tree" command to display the structure of the small output directory
tree -ah analyze_small_output/
# analyze_small_output/
# ├── [ 4.0K]  bins
# │   └── [ 4.0K]  B1838859_S01_L001_contigs
# │       ├── [ 850K]  genes.faa
# │       ├── [ 484K]  genes.gff
# │       └── [ 2.6M]  hmmer.analyze.txt
# ├── [  969]  checkm.log
# └── [ 4.0K]  storage
#     ├── [ 4.0K]  aai_qa
#     │   └── [ 4.0K]  B1838859_S01_L001_contigs
#     │       ├── [  427]  PF02222.17.masked.faa
#     │       └── [  407]  PF10004.4.masked.faa
#     ├── [  433]  bin_stats.analyze.tsv
#     └── [ 100K]  checkm_hmm_info.pkl.gz

# 5 directories, 8 files

# Run CheckM's quality assessment (QA) on the small dataset
checkm \
  qa \
  --file checkm.small.tax.qa.out \
  --out_format 1 \
  --threads 8 \
  Ng.markers \
  analyze_small_output

# [2025-02-27 21:40:14] INFO: CheckM v1.2.3
# [2025-02-27 21:40:14] INFO: checkm qa --file checkm.small.tax.qa.out --out_format 1 --threads 8 Ng.markers analyze_small_output
# [2025-02-27 21:40:14] INFO: CheckM data: /storage/home/hhive1/calnoubani3/data/checkm/db
# [2025-02-27 21:40:14] INFO: [CheckM - qa] Tabulating genome statistics.
# [2025-02-27 21:40:14] INFO: Calculating AAI between multi-copy marker genes.
# [2025-02-27 21:40:14] INFO: Reading HMM info from file.
# [2025-02-27 21:40:14] INFO: Parsing HMM hits to marker genes:
#     Finished parsing hits for 1 of 1 (100.00%) bins.
# [2025-02-27 21:40:15] INFO: QA information written to: checkm.small.tax.qa.out
# [2025-02-27 21:40:15] INFO: { Current stage: 0:00:00.325 || Total: 0:00:00.325 }

# Check and display the size of the small dataset QA output file
du -sh checkm.small.tax.qa.out
# 512     checkm.small.tax.qa.out

# Display the contents of the small dataset QA output file
cat checkm.small.tax.qa.out
# ----------------------------------------------------------------------------------------------------------------------------------------# --------------------------------------------
#   Bin Id                            Marker lineage        # genomes   # markers   # marker sets   0     1     2   3   4   5+     Completeness   Contamination   Strain heterogeneity
# ----------------------------------------------------------------------------------------------------------------------------------------# --------------------------------------------
#   B1838859_S01_L001_contigs   Neisseria gonorrhoeae (6)       14         1201          205        14   1185   2   0   0   0       99.25            # 0.24              50.00
# ----------------------------------------------------------------------------------------------------------------------------------------# --------------------------------------------

# Use the "tree" command to display the structure of the large output directory
tree -ah analyze_large_output/
# analyze_large_output/
# ├── [ 4.0K]  bins
# │   └── [ 4.0K]  B1299860_S01_L001_contigs
# │       ├── [ 847K]  genes.faa
# │       ├── [ 495K]  genes.gff
# │       └── [ 2.6M]  hmmer.analyze.txt
# ├── [  969]  checkm.log
# └── [ 4.0K]  storage
#     ├── [ 4.0K]  aai_qa
#     │   └── [ 4.0K]  B1299860_S01_L001_contigs
#     │       ├── [  427]  PF02222.17.masked.faa
#     │       └── [  406]  PF10004.4.masked.faa
#     ├── [  449]  bin_stats.analyze.tsv
#    └── [ 100K]  checkm_hmm_info.pkl.gz

# 5 directories, 8 files

# Run CheckM's quality assessment (QA) on the large dataset
checkm \
  qa \
  --file checkm.large.tax.qa.out \
  --out_format 1 \
  --threads 8 \
  Ng.markers \
  analyze_large_output

# [2025-02-27 21:45:54] INFO: CheckM v1.2.3
# [2025-02-27 21:45:54] INFO: checkm qa --file checkm.large.tax.qa.out --out_format 1 --threads 8 Ng.markers analyze_large_output
# [2025-02-27 21:45:54] INFO: CheckM data: /storage/home/hhive1/calnoubani3/data/checkm/db
# [2025-02-27 21:45:54] INFO: [CheckM - qa] Tabulating genome statistics.
# [2025-02-27 21:45:54] INFO: Calculating AAI between multi-copy marker genes.
# [2025-02-27 21:45:54] INFO: Reading HMM info from file.
# [2025-02-27 21:45:54] INFO: Parsing HMM hits to marker genes:
#     Finished parsing hits for 1 of 1 (100.00%) bins.
# [2025-02-27 21:45:55] INFO: QA information written to: checkm.large.tax.qa.out
# [2025-02-27 21:45:55] INFO: { Current stage: 0:00:00.295 || Total: 0:00:00.295 }

# Check and display the size of the large dataset QA output file
du -sh checkm.large.tax.qa.out
# 512     checkm.large.tax.qa.out

# Display the contents of the large dataset QA output file 
cat checkm.large.tax.qa.out
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Bin Id                            Marker lineage        # genomes   # markers   # marker sets   0     1     2   3   4   5+   Completeness   Contamination   Strain heterogeneity
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  B1299860_S01_L001_contigs   Neisseria gonorrhoeae (6)       14         1201          205        13   1186   2   0   0   0       99.49            0.24              50.00
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


