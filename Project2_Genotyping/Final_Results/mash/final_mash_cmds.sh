#ran on mac_arm64 with M1 chip
conda create -n group3
conda activate group3
conda install mash
brew install brewsci/bio/mlst #ran into issues conda installing mlst but this works for my mac

#calculate mash distances from the reference genome (N. gonorrehea 1090) for every assembly and outputted to one text file
mash dist group3/reference.fna B2/final_contigs/*.fa > ./group3/mash_results/mash_output 
#double check it ran completely
wc -l mash_output
cat mash_output
