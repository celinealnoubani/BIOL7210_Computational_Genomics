# Genotyping and Taxonomic and Quality Assessments in-class exercises

## Specific Learning Objectives
1. compute pairwise ANI for species naming
1. genotype a genome assembly (with MLST)
1. estimate a genome assembly's completeness and contamination relative to previously studied assemblies for the target taxon
1. learn how to quickly insert header lines to output files that lack them
1. identify the value of post-process filtering of a raw assembly
1. form bash arrays from mixed file extensions
1. learn nested bash for-loops as a solution to compute pairwise comparisons of a file list

### Resources
1. FastANI
    - original [manuscript](https://pubmed.ncbi.nlm.nih.gov/30504855/)
    - code repository [here](https://github.com/ParBLiSS/FastANI)
2. MLST
    - code repository [here](https://github.com/tseemann/mlst)
    - data interpretation [here](https://github.com/tseemann/mlst?tab=readme-ov-file#missing-data)
3. CheckM
    - original [manuscript](http://genome.cshlp.org/content/25/7/1043)
    - code repository [here](https://github.com/Ecogenomics/CheckM)
    - tutorial [here](https://github.com/Ecogenomics/CheckM/wiki/Workflows#lineage-specific-workflow)


### In-class Exercises
#### Taxonomic Exercise
NCBI reports [this assembly](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_001879185.2/) is contaminated and has too many frame-shifted proteins. So although it remains in GenBank, it is excluded from RefSeq. We will evaluate this assembly further.

1. Setup the working directory, fetch the compressed assembly FastA files, decompress, and verify they look right
    ```bash
    mkdir -pv ~/ex5/fastani
    cd ~/ex5/fastani
    curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/879/185/GCA_001879185.2_ASM187918v2/GCA_001879185.2_ASM187918v2_genomic.fna.gz
    curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/254/515/GCF_000254515.1_ASM25451v2/GCF_000254515.1_ASM25451v2_genomic.fna.gz
    gunzip -kv *.fna.gz
    head -n 2 *.fna
    tail -n 1 *.fna
    grep '>' *.fna
    ```

2. Rename to make this simpler
    ```bash
    mv -v \
     GCF_000254515.1_ASM25451v2_genomic.fna \
     reference.fna
    mv -v \
     GCA_001879185.2_ASM187918v2_genomic.fna \
     problem.fna
    ```

3. Compare the "contaminated" problem assembly to the species type strain
    ```bash
    conda create -n fastani -c bioconda fastani -y
    conda activate fastani
    fastANI \
      --query problem.fna \
      --ref reference.fna \
      --output FastANI_Output.tsv
    awk \
      '{alignment_percent = $4/$5*100} \
      {alignment_length = $4*3000} \
      {print $0 "\t" alignment_percent "\t" alignment_length}' \
      FastANI_Output.tsv \
      > FastANI_Output_With_Alignment.tsv
    # Note: this only works for GNU sed (e.g., in Ubuntu, WSL2, etc.)
    sed \
      "1i Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%Query_Aligned\tBasepairs_Query_Aligned" \
      FastANI_Output_With_Alignment.tsv \
      > FastANI_Output_With_Alignment_With_Header.tsv
    # This will work in MacOS to avoid BSD sed
    awk 'BEGIN \
      {print "Query\tReference\t%ANI\tNum_Fragments_Mapped\tTotal_Query_Fragments\t%Query_Aligned\tBasepairs_Query_Aligned"} \
      {print}' \
      FastANI_Output_With_Alignment.tsv \
      > FastANI_Output_With_Alignment_With_Header.tsv

    column -ts $'\t' FastANI_Output_With_Alignment_With_Header.tsv | less -S
    ```

#### Genotyping Exercise
4. Perform MLST
- NOTE: conda (or mamba) will likely take too long to install the `mlst` package suite, so consider docker as an alternative
    - MLST with Docker
        ```bash
        # NOTE: the container https://hub.docker.com/layers/staphb/mlst/latest/images/sha256-406f8422365b37ef7ac100a5dbc2cdf319d1965b32bf4f46cf2832f986348b7c
        #       specifies "OS/ARCH linux/amd64", so we know that is supported, and we can specify the platform when pulling it
        # This platform specified works for MacOS rosetta2 x64 emulated and WSL2 with Ubuntu using x64 CPU
        docker pull \
         staphb/mlst:latest \
         --platform=linux/amd64
        # Go into interactive "-it" mode, read/write ~/ex5 to /local container path, use mlst container with bash
        docker run \
         -it \
         --mount type=bind,src=$HOME/ex5,target=/local \
         staphb/mlst \
         bash
        cd /local/fastani
        mlst *.fna > MLST_Summary.tsv
        exit
        cd ~/ex5/fastani
        cat MLST_Summary.tsv
          #  problem.fna	campylobacter	8536	aspA(40)	glnA(1)	gltA(1)	glyA(3)	pgm(2)	tkt(1)	uncA(6)
          #  reference.fna	campylobacter	403	aspA(10)	glnA(27)	gltA(16)glyA(19)	pgm(10)	tkt(5)	uncA(7)
          # RESULTS: wow, they're different genotypes(!) ST-8536 -vs- ST-403
        ```

    - MLST with Conda
        ```bash
        mkdir -pv ~/ex5/mlst
        cd ~/ex5/mlst
        ln -sv ../fastani/problem.fna .
        conda create -n mlst -c conda-forge -c bioconda mlst -y
        conda activate mlst
        mlst *.fna > MLST_Summary.tsv
        column -ts $'\t' FastANI_Output_With_Alignment_With_Header.tsv | less -S
        ```

#### Quality Assessments Exercise
5. Evaluate the assembly itself
   - for Linux x86_64 and MacOS x86_64:
        ```bash
        mkdir -pv ~/ex5/checkm/{asm,db}
        cd ~/ex5/checkm/asm
        ln -sv ../../fastani/problem.fna .
        cd ~/ex5/checkm/db
        # Download took me 5 min
        curl -O https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
        tar zxvf checkm_data_2015_01_16.tar.gz
        # For Ubuntu using bash as shell
        echo 'export CHECKM_DATA_PATH=$HOME/ex5/checkm/db' >> ~/.bashrc
        source ~/.bashrc
        # For MacOS using bash as shell:
        echo 'export CHECKM_DATA_PATH=$HOME/ex5/checkm/db' >> ~/.bash_profile
        source ~/.bash_profile
        echo "${CHECKM_DATA_PATH}"
        conda create -n checkm -c conda-forge -c bioconda checkm-genome -y
        conda activate checkm
        cd ~/ex5/checkm
        checkm data setRoot db/
            # Path [/Users/cg/ex5/checkm/db] exists and you have permission to write to this folder.
            # (re) creating manifest file (please be patient).
        checkm taxon_list | grep Campylo
        checkm taxon_set species "Campylobacter jejuni" Cj.markers
        checkm \
          analyze \
          --threads 8 \
          Cj.markers \
          ~/ex5/checkm/asm \
          analyze_output
        # View output structure
        tree -ah analyze_output/
              #  [ 160]  analyze_output/
              #  ├── [  96]  bins
              #  │   └── [ 160]  problem
              #  │       ├── [720K]  genes.faa
              #  │       ├── [389K]  genes.gff
              #  │       └── [2.2M]  hmmer.analyze.txt
              #  ├── [1.1K]  checkm.log
              #  └── [ 160]  storage
              #      ├── [  96]  aai_qa
              #      │   └── [ 128]  problem
              #      │       ├── [ 774]  PF00310.16.masked.faa
              #      │       └── [ 331]  PF13353.1.masked.faa
              #      ├── [ 401]  bin_stats.analyze.tsv
              #      └── [113K]  checkm_hmm_info.pkl.gz
              #
              #  6 directories, 8 files
        checkm \
          qa \
          --file checkm.tax.qa.out \
          --out_format 1 \
          --threads 8 \
          Cj.markers \
          analyze_output
        du -sh checkm.tax.qa.out
              # 4.0K	checkm.tax.qa.out
        cat checkm.tax.qa.out
              # ---------------------------------------------------------------------------------------------------------------------------------------------------------------
              #   Bin Id         Marker lineage        # genomes   # markers   # marker sets   0    1    2   3   4   5+   Completeness   Contamination   Strain heterogeneity
              # ---------------------------------------------------------------------------------------------------------------------------------------------------------------
              #   problem   Campylobacter jejuni (6)       20         903           161        6   895   2   0   0   0       99.29            0.20               0.00
              # ---------------------------------------------------------------------------------------------------------------------------------------------------------------
        ```

   - for MacOS ARM64:
        ```zsh
            mkdir -pv ~/ex5/checkm/{asm,db}
            cd ~/ex5/checkm/asm
            ln -sv ../../fastani/problem.fna .
            cd ~/ex5/checkm/db
            # Download took me 5 min
            curl -O https://zenodo.org/records/7401545/files/checkm_data_2015_01_16.tar.gz
            tar zxvf checkm_data_2015_01_16.tar.gz
            echo 'export CHECKM_DATA_PATH=$HOME/ex5/checkm/db' >> ~/.zshrc
            source ~/.zshrc
            echo "${CHECKM_DATA_PATH}"
            conda create -n checkm python=3.9 -y
            conda install -c bioconda numpy matplotlib pysam -y
            conda install -c bioconda hmmer -y
            pip3 install checkm-genome
               # NOTE: missing pplacer ARM64, difficult to compile, but otherwise this will work. Know the algorithms well and these install issues you can skip without sacrificing the commands you need to run (pplacer not required for these specific subcommands).
            cd ~/ex5/checkm
            checkm taxon_list | grep Campylo
            checkm taxon_set species "Campylobacter jejuni" Cj.markers
            checkm \
              analyze \
              Cj.markers \
              ~/ex5/checkm/asm \
              analyze_output
            checkm \
              qa \
              -f checkm.tax.qa.out \
              -o 1 \
              Cj.markers \
              analyze_output
            column -ts $'\t' checkm.tax.qa.out | less -S
     ```

##### Pairwise bash tricks for FastANI

1. Form a bash array (list of files to be analyzed). This assumes assemblies are "fa" or "fna" file extensions in the current working directory.
    ```bash
    shopt -s nullglob
    assemblies=( *.{fa,fna} )
    shopt -u nullglob
    ```

2. Perform pairwise comparisons using the store array containing filepaths as input
    ```bash
    for ((i = 0; i < ${#assemblies[@]}; i++)); do 
      for ((j = i + 1; j < ${#assemblies[@]}; j++)); do 
        echo "${assemblies[i]} and ${assemblies[j]} being compared..."
        fastANI \
         -q ${assemblies[i]} \
         -r ${assemblies[j]} \
         -o FastANI_Outdir_${assemblies[i]}_${assemblies[i]}.tsv
      done
    done
    ```

3. View ANI values
    ```bash
    awk '{print $1, $2, $3}' FastANI_Outdir_*.txt
    ```


### Homework Assignment
(3) *Bordetella parapertussis* isolates were sequenced as part of national surveillance in Colombia [here](https://journals.asm.org/doi/10.1128/mra.00672-24). SRA accessions are on NCBI for each:
  -  [SRR27160580](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR27160580&display=metadata)
  -  [SRR27160579](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR27160579&display=metadata)
  -  [SRR27160578](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR27160578&display=metadata)

Use all (3) SRA accessions above and fetch the Illumina sequence data from NCBI. Perform `fastANI` against the species type strain. You will have to find and fetch a type strain genome.

Use previously learned skills from the class:
1. Fetch all read sets with sra-tools as performed previously with `fasterq-dump` or `fastq-dump`
1. Quick read clean with `fastp` or whatever you're most comfortable with
1. Quick assembly with `skesa` or whatever you're most comfortable with
1. Filter out low coverage and short contigs
1. Verify filesizes look similar with `ls -alh *.fna` in your output directory containing all assemblies. If they're not similar in filesizes, refine trim and assembly parameters. All 3 are _highly related_, so they should have near identical assembly sizes too.

Genotype all 3 assemblies with MLST. For just 1 assembly of the 3, estimate its completeness and contamination levels.

### Homework Grade Distribution
Upload a single compressed archive file **`assembly_assessment.tar.gz`** to Canvas containing:
1. **30%** grade:  Table of FastANI output for assembled SRA samples against the type strain in plain text format. Submit as `fastani.tsv`
    - 15% accessions only listed as sample names in table
    - 15% data values in the table
1. **30%** grade:  Table of MLST output for assembled SRA samples and the type strain in plain text format. Submit as `mlst.tsv`
    - 15% accessions only listed as sample names in table
      - 5% for each of the (3) samples
    - 15% data values in the table
      - 5% for each of the (3) samples
1. **20%** grade:  Here you can choose CheckM, CheckM2, or BUSCO but be sure to specify in your cmds.sh file which you did. Provide a tab-delimited summary file on just 1 genome of the 3 assembly files the level of completeness and contamination, stored as `quality.tsv` with a header naming your data columns.
    - 10% header
    - 10% data content
      - 5% genome completeness
      - 5% genome contamination
1. **20%** grade:  upload `cmds.sh` containing all commands you invoked for this entire project. Please continue to practice commenting!
