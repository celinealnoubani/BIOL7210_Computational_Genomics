# Fastani Prelim Results  
This directory contains the results of tsv tables that contain the Fastani Results from the smallest and largest files.  
Said Raw data/Reference can be found directly in the B3 folder. 

# Contents  
Fastani tsv files: Contains (Query,	Reference,	%ANI,	Num_Fragments_Mapped,	Total_Query_Fragments,	%Query_Aligned,	Basepairs_Query_Aligned)  
Script: Contains the script used to run unzip/move/rename files, run FastANI, and modify the resulting tsv tables  
LogFiles: Contain Terminal output for each run; contains information like AvgFragmentLength(3000), KmerSize(16), threads(1), etc.  

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
