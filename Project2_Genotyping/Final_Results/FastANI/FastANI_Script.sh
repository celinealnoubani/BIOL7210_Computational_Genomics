#!/bin/bash

mkdir -pv ./Fastani ./FastaniLog ./FastaniFinalOutput

Final_Contigs="$1"

if [[ -e "./file" ]]; then
    unpigz ./ASM684v1_reference.fna.gz
fi

for file in "$Final_Contigs"/*; do
    if [[ $file == *.fa.gz ]]; then
        unpigz $file
    fi
done

for file in "$Final_Contigs"/*.fa; do
    Base=$(basename "$file" | awk -F'_' '{print $1}')
    (fastANI --query $file --ref "./ASM684v1_reference.fna" --output ./Fastani/FastANI1_${Base}.tsv) 2>&1 | tee ./FastaniLog/${Base}fastani.log
    awk '{alignment_percent = $4/$5*100} {alignment_length = $4*3000} {print $0 "\t" alignment_percent "\t" alignment_length}' ./Fastani/FastANI1_${Base}.tsv > ./Fastani/FastANI1_${Base}wAlignment.tsv
    echo -en "${Base}\tASM684v1\t" > ./Fastani/FastANI_${Base}Output.tsv
    cut -f3- ./Fastani/FastANI1_${Base}wAlignment.tsv >> ./Fastani/FastANI_${Base}Output.tsv
    rm ./Fastani/FastANI1_${Base}.tsv ./Fastani/FastANI1_${Base}wAlignment.tsv
done

cat ./Fastani/* > ./Fastani/Fastani_noheader.tsv

{ printf "Query\tReference\t%%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%%Query_Aligned\tBasepairs_Query_Aligned\n"; cat ./Fastani/Fastani_noheader.tsv; } > ./FastaniFinalOutput/Fastani_Output_Table.tsv
