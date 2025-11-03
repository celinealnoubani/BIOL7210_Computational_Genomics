#ran on mac_arm64 with M1 chip
conda create -n group3
conda activate group3
conda install mash
brew install brewsci/bio/mlst #ran into issues conda installing mlst but this works for my arm64 mac

#run MLST on all 34 assemblies and save results in one output file
mlst B2/final_contigs/*.fa > ./group3/mlst_results/mlst_output.tsv 

#double check it ran correctly
wc -l mlst_output.tsv
cat mlst_output.tsv
