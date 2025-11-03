# conda create -n fastani -c bioconda fastani pigz -y; this should be created and activated
mkdir -pv ~/fastani/B1838859
mkdir -pv ~/fastani/B1299860

cd ~/fastani
# move the downloaded reference zipped file and the contig zipped files into their respective places (ie contig goes in the folder with the respective name and the reference goes directly in the main folder)
unpigz *.fna.gz
unpigz -kv *.fa.gz


mv -v GCF_000006845.1_ASM684v1_genomic.fna ASM684v1_reference.fna # rename reference file

mv -v B1838859_S01_L001_contigs.fa ./B1838859/B1838859_problem.fna # rename and move problem file, keep the identifier

(fastANI --query ./B1838859/B1838859_problem.fna --ref ./ASM684v1_reference.fna --output ./B1838859/FastANI_B1838859Output.tsv) 2>&1 | tee ./B1838859/B1838859fastani.log
# run fastani

awk '{alignment_percent = $4/$5*100} {alignment_length = $4*3000} {print $0 "\t" alignment_percent "\t" alignment_length}' ./B1838859/FastANI_B1838859Output.tsv > ./B1838859/FastANI_B1838859Output_With_Alignment.tsv
# add alignment percent and alignment length

{ printf "Query\tReference\t%%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%%Query_Aligned\tBasepairs_Query_Aligned\n"; cat ./B1838859/FastANI_B1838859Output_With_Alignment.tsv; } > ./B1838859/FastANI_B1838859Output_With_Alignment_With_Header.tsv
# add headers



mv -v B1299860_S01_L001_contigs.fa ./B1299860/B1299860_problem.fna

(fastANI --query ./B1299860/B1299860_problem.fna --ref ./ASM684v1_reference.fna --output ./B1299860/FastANI_B1299860Output.tsv) 2>&1 | tee ./B1299860/B1299860fastani.log
# run fastani

awk '{alignment_percent = $4/$5*100} {alignment_length = $4*3000} {print $0 "\t" alignment_percent "\t" alignment_length}' ./B1299860/FastANI_B1299860Output.tsv > ./B1299860/FastANI_B1299860Output_With_Alignment.tsv
# add alignment percent and alignment length

{ printf "Query\tReference\t%%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%%Query_Aligned\tBasepairs_Query_Aligned\n"; cat ./B1299860/FastANI_B1299860Output_With_Alignment.tsv; } > ./B1299860/FastANI_B1299860Output_With_Alignment_With_Header.tsv
# add headers
