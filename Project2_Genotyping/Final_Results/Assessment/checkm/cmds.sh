# CheckM Command Script 

# This script creates the required directory structure for CheckM, uncompresses the assembly files, downloads and extracts the CheckM database, and then sets up the environment by configuring the CHECKM_DATA_PATH variable and activating the Conda CheckM environment. Finally, it initializes CheckM by setting the database root and generating a taxon-specific marker set for Neisseria gonorrhoeae.

# Make a Checkm directory & navigate into it
mkdir checkm
cd checkm/
# Make an assembly directory along with a database directory for CheckM's reference data to go
mkdir asm
mkdir db
# Navigate into the asm directory and manually upload assembly files 
cd asm
# Uncompress the assembly files
gunzip *contigs.fa.gz
# Navigate back into db directory
cd ..
cd db
# Retrieve CheckM data
curl -O https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
# Extract the CheckM data
tar zxvf checkm_data_2015_01_16.tar.gz
# Find out my home path 
$HOME
# /home/hice1/calnoubani3

# Append the export command to .bashrc to permanently set the CHECKM_DATA_PATH environment variable
echo 'export CHECKM_DATA_PATH=$HOME/Documents/B3_Final/checkm/db' >> ~/.bashrc

# Ensure it was set correctly 
echo "${CHECKM_DATA_PATH}"
# /home/hice1/calnoubani3/Documents/B3_Final/checkm/db

module load anaconda3 

# Use checkm_environmrnt.yml file to activate checkm environment 
conda env create -f checkm_environment.yml
conda activate checkm
conda list | grep checkm
# packages in environment at /home/hice1/calnoubani3/.conda/envs/checkm:
# checkm-genome             1.2.3              pyhdfd78af_1    bioconda

checkm data setRoot db/
# [2025-03-25 08:54:31] INFO: CheckM v1.2.3
# [2025-03-25 08:54:31] INFO: checkm data setRoot db/
# [2025-03-25 08:54:31] INFO: CheckM data: /home/hice1/calnoubani3/Documents/B3_Final/checkm/db
# [2025-03-25 08:54:31] INFO: [CheckM - data] Check for database updates. [setRoot]

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

