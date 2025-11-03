# Fastani Results  
This directory contains the results of all 34 Samples; tsv files, log files, starting data, barchart, and script.  
Said Raw data/Reference can be found directly in the B3 folder. 

# Contents  
FastaniFinalOutput: Contains single tsv file containing (Query,	Reference,	%ANI,	Num_Fragments_Mapped,	Total_Query_Fragments,	%Query_Aligned,	Basepairs_Query_Aligned) for all 34 contig files   
FastANI_Script.sh: Script used to unzip files, run FastANI, and modify the resulting tsv tables into a single table; is automated and now accepts a Contig_Folder  ./FastANI_Script.sh <Contig_Folder>
FastaniLog: Contain Terminal output for each run; contains information like AvgFragmentLength(3000), KmerSize(16), threads(1), etc. 
ASM684v1_reference.fna.gz: reference genome  
FastaniBarChart.png: Bar graph that compares the %ANI scores for each sample  
Final_Contigs: contains the contigs from the 34 sample  

# System Specifications  
### The following OS and hardware specifications were used for processing:  

Architecture: x86_64 (Apple Silicon)  
Chip: 1.6 GHz Dual-Core Intel Core i5  
Cores: 4 (2 physical cores)  
Memory: 8 GB 2133 MHz LPDDR3  
Operating System: Darwin Kernel Version 23.6.0 (macOS Sonoma) 

# Tools Used  
FastANI: version 1.34  
pigz: pigz 2.8  
Python: 3.10.14  
