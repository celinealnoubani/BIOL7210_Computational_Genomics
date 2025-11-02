# Gene Prediction in-class Exercises

## Specific Learning Objectives
1. use hidden markov model-based approach for gene sequence extraction from a genome
1. use ab initio algorithm to predict protein-encoding gene sequences in a genome
1. use homology-based methods to infer function of nucleotide and protein sequences
1. learn how to combine stdout and stderr of a system command to store a single logfile while simultaneously being able to view the lines print as the command progresses
1. understand when webservers (e.g., due to database sizes) can still be useful in modern bioinformatics

**We will do (2) different approaches today:**
1. 16S rRNA (small subunit ["ssu"]) gene sequence extraction
1. prediction of all protein-encoding gene sequences from an isolate's genome assembly

## 16S rRNA Gene Sequence Extraction

1. Create conda environment with software for this first part of the exercise
    ```
    conda create -n ex4_pt1 -y
    ```

1. Go into the ex4_pt1 environment and install barrnap (bedtools is a dependency we'll also use) from the bioconda channel as priority over the conda-forge channel
   -  NOTE: as of 21-JAN-2025 this works with ARM64 and Intel chips
       ```bash
       conda activate ex4_pt1
       conda install -c bioconda -c conda-forge barrnap bedtools -y
       barrnap --version     # mine was v0.9
       bedtools --version    # mine was v2.31.1
       ```

1. Setup work directory and fetch small bacterial genome assembly file (0.58 Mbp, *Mycoplasma genitalium*)
    ```bash
    mkdir -pv ~/ex4/{cds,ssu}
    cd ~/ex4/ssu
    curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/325/GCF_000027325.1_ASM2732v1/GCF_000027325.1_ASM2732v1_genomic.fna.gz
    gunzip -k *.fna.gz
    ```

1. Identify the 16S rRNA gene sequence coordinates (GFF format), then extract the nucleotide sequence (as FastA format)
    ```bash
    barrnap \
     GCF_000027325.1_ASM2732v1_genomic.fna \
     | grep "Name=16S_rRNA;product=16S ribosomal RNA" \
     > 16S.gff
    du -sh 16S.gff    # 4.0K : 16S.gff
    bedtools getfasta \
     -fi GCF_000027325.1_ASM2732v1_genomic.fna \
     -bed 16S.gff -s \
     -fo 16S.fa
    du -sh 16S.fa     # 4.0K : 16S.fa
    grep '>' 16S.fa
    cat 16S.fa
    ```

1. Cleanup
    ```bash
    rm -v *.{fai,gff}
    conda deactivate
    ```

## Coding Sequence (CDS) Prediction

- For Linux x86_64 and MacOS x64_64, conda will work for prodigal to install quick and easy:
    1. Create new env for part2
        ```zsh
        conda create -n ex4_pt2 -y
        ```
    
    1. Go into the ex4_pt1 environment and install prodigal
        ```zsh
        conda activate ex4_pt2
        conda install -c bioconda -c conda-forge prodigal pigz -y
        ```

- For MacOS ARM64, you'll have to compile from src (requiring [XCode](https://developer.apple.com/xcode/)) and `gcc`:
    1. Clone the repo to your device
        ```
        git clone https://github.com/hyattpd/Prodigal.git $HOME/Prodigal
        ```
    
    1. Confirm you have `gcc`
         ```zsh
         which -p gcc
             # mine showed "/usr/bin/gcc"
         gcc --version
             # mine showed:
             #   Apple clang version 16.0.0 (clang-1600.0.26.6)
             #   Target: arm64-apple-darwin24.2.0
             #   Thread model: posix
             #   InstalledDir: /Library/Developer/CommandLineTools/usr/bin
         ```

    1. Compile the `prodigal` C++ binary
          ```zsh
          cd ~/Prodigal
          make
              # NOTE: I saw (4) lines print with warnings:
              # "warning: a function declaration without a prototype is deprecated in all versions of C [-Wstrict-prototypes]"
              # but the binary was still operational
          ```
  
    1. Test the binary out (NOTE: without modifying your ~/.zshrc $PATH, you'll always have to give the full path to run it)
          ```zsh
           ~/Prodigal/prodigal -v
               # Mine printed "Prodigal V2.6.3: February, 2016"
          ```

1. Get back into working directory, and verify our assembly file is still there from part1 (expect 574K filesize)
    ```bash
    cd ~/ex4/cds
    ls -lh ~/ex4/ssu/*.fna
        # 574K : $HOME/ex4/ssu/GCF_000027325.1_ASM2732v1_genomic.fna
    ```

1. Perform _ab initio_ coding sequence prediction (for bacterial isolate), storing stderr and stdout as a single logfile, while also being able to view on the interactive terminal and then print information
    ```bash
    prodigal \
     -i ~/ex4/ssu/GCF_000027325.1_ASM2732v1_genomic.fna \
     -c \
     -m \
     -f gbk \
     -o cds.gbk \
     2>&1 | tee log.txt
    du -sh log* cds*
         # 4.0K : log.txt
         # 232K : cds.gbk
    ```

1. Compress and view file output
    ```bash
    pigz -9f *.gbk log.txt
    zcat *.gbk.gz | head -n 4
    zcat log.txt.gz
    ```

# Functional Annotation in-class exercise

We'll use one online **GUI** and one **CLI** tool to predict genes in a prokaryotic genome. Note the database sizes!

### Resources
1. InterPro
    - original [manuscript](https://pubmed.ncbi.nlm.nih.gov/11159333/)
    - newest 2023 db paper [here](https://pubmed.ncbi.nlm.nih.gov/36350672/)
    - cli newest search algorithm [manuscript](https://pubmed.ncbi.nlm.nih.gov/24451626/)
    - cli search algorithm [repo](https://github.com/ebi-pf-team/interproscan)
    - **webGUI** db + search algorithm [link](https://www.ebi.ac.uk/interpro/)
    - video resource [here](https://www.youtube.com/watch?v=EWLGFuTpUnQ)
2. eggNog ("evolutionary genealogy of genes: Non-supervised Orthologous Groups")
    - original [manuscript](https://pubmed.ncbi.nlm.nih.gov/17942413/)
    - newest 2023 db paper [here](https://pubmed.ncbi.nlm.nih.gov/36399505/)
    - cli [manuscript](https://pubmed.ncbi.nlm.nih.gov/34597405/)
    - cli search algorithm [repo](https://github.com/eggnogdb/eggnog-mapper)
    - **webGUI** db + search algorithm [link](http://eggnog-mapper.embl.de/)
    - video resource [here](https://www.youtube.com/watch?v=OrKViOoPX7U)

### in-class Exercise
For the functional annotation exercise,

  1. Download FastA sequences of proteins in the Aux5 clusters in this repo
  1. Annotate the sequences using InterPro (Web GUI) and EggNOG (CLI or GUI).

Please keep in mind that this is a more **biologically-oriented** assignment. Look up the domains, motifs, and annotations to understand the role of each of these proteins.

## Homework Assignment
1. document all of your shell commands for this assignment in a plain text "cmds.sh" file
1. fetch [the GCF_037966535.1 RefSeq assembly](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_037966535.1/) - recently described in [Jan 2025](https://journals.asm.org/doi/10.1128/mra.00562-24), where [Table 1](https://journals.asm.org/doi/10.1128/mra.00562-24#T1) lists 2 rRNA operons exist
1. Choose 1 of 3 packages
    - "No one tool to rule them all" [manuscript](https://pubmed.ncbi.nlm.nih.gov/34875010/)
    1. GeneMark [src](http://topaz.gatech.edu/GeneMark/license_download.cgi) [manuscript](https://pubmed.ncbi.nlm.nih.gov/29773659/)
    1. GLIMMER [src](http://ccb.jhu.edu/software/glimmer/index.shtml) [manuscript](https://pubmed.ncbi.nlm.nih.gov/17237039/)
    1. Prodigal [src](https://github.com/hyattpd/Prodigal) [manuscript](https://pubmed.ncbi.nlm.nih.gov/20211023/)
4. Predict all coding sequences in the bacterial isolate genome, and store stderr and stdout logfile as a single plaintext ".log" file
5. Choose 1 of 2 packages
    1. RNAmmer [src](https://services.healthtech.dtu.dk/services/RNAmmer-1.2/5-Supplementary_Data.php) [manuscript](https://pubmed.ncbi.nlm.nih.gov/17452365/)
    1. barrnap [src](https://github.com/tseemann/barrnap) no-manuscript-exists
6. Extract *all* 16S rRNA gene sequences from the assembly file, stored as gunzip compressed FastA format
7. Use extracted 16S FastA extracted sequence(s) from this homework exercise (step #6) to identify the top 5 hits. Include all pertinent alignment information, which would guide a final decision in identifying the isolate to **species-level**, and sort your best match to the *top*. [Here](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome) is the main webGUI page, but this is a lesson on database importance and alignment results interpretation. The appropriate database must be selected (hint, it's not the default) or results will be unhelpful. Submit as "top_ssu_alignments.xlsx" and remember to include a header row.
9. Compress all submission files as a single .tar.gz

## Homework Grade Distribution
- Submit (1) `gene.tar.gz` file to Canvas containing all (5) files:
    1. **10%** grade:  upload `cmds.sh` containing all commands you invoked for this entire project; practice commenting!
        - 5% commenting
        - 5% system commands
    1. **30%** grade:  upload 16S sequence file (compressed) `16S.fa.gz`
        - 10% nucleotide sequence content
        - 10% approximately correct sequence length
        - 10% appropriate defline (header)
    1. **20%** grade:  upload CDS prediction file (compressed) `cds.gff.gz`
    1. **10%** grade:  upload CDS prediction logfile (compressed) `cds.log.gz`
    1. **30%** grade:  upload 16S blast results file `top_ssu_alignments.xlsx`
        - 10% header
        - 10% top 5 alignments
        - 10% correct best match on top
  - only filenames with *exact* regex matches will be graded
