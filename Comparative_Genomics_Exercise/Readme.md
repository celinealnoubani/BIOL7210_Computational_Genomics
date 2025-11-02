# Comparative Genomics in-class exercise

## Specific Learning Objectives
1. identify core SNP mutations among highly related genomes with assembly- and read-based methods
1. infer a phylogeny for outbreak analysis
1. learn how to use bash string manipulation for handling paired-end data files
1. learn and explore graphical manipulation of genome data to enable conclusions to be drawn from complex datasets

### Resources
1. ParSNP within the harvest suite
    - original [manuscript](https://pubmed.ncbi.nlm.nih.gov/25410596/)
    - code repository [here](https://github.com/marbl/parsnp)
    - tutorial [here](https://harvest.readthedocs.io/en/latest/content/parsnp/tutorial.html)
2. Snippy
    - unpublished
    - code repository [here](https://github.com/tseemann/snippy)
    - tutorial using Galaxy (not CLI) [here](http://sepsis-omics.github.io/tutorials/modules/snippy/)
3. BinDash
    - original [manuscript](https://pubmed.ncbi.nlm.nih.gov/30052763/)
    - code repository [here](https://github.com/zhaoxiaofei/bindash)


### In-class Exercise
(10) *Listeria monocytogenes* isolates were sequenced as part of an outbreak analysis. SRA accessions are on NCBI for each:
  -  SRR1556294
  -  SRR1556293
  -  SRR1556289
  -  SRR1556296
  -  SRR1556290
  -  SRR1556291
  -  SRR1556297
  -  SRR1556295
  -  SRR1556288
  -  SRR1553827

Initially in-class just focus on SRR1556289, SRR1556296, and SRR1556290. The _**SRR1556288**_ has a complete genome assembly [GCF_001047715.2](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/047/715/GCF_001047715.2_ASM104771v2/GCF_001047715.2_ASM104771v2_genomic.fna.gz) from PacBio sequencing chemistry, and it should be used as the **reference**. All 3 are part of the outbreak, so get software working well (start-to-finish) first on this small subset.

##### Use previously learned skills from the class
`mkdir ~/ex6`

1. Fetch all 3 read sets with sra-tools as performed previously with `fasterq-dump` (e.g., `conda activate ex3`)
    ```bash
    mkdir -pv ~/ex6/Raw_FastQs
    cd ~/ex6/Raw_FastQs
    for accession in SRR1556289 SRR1556296 SRR1556290; do
        prefetch "${accession}"
    done
    for accession in SRR1556289 SRR1556296 SRR1556290; do
      fasterq-dump \
       "${accession}" \
       --outdir . \
       --split-files \
       --skip-technical
    done
    pigz -9 *.fastq
    ```

1. Quick read clean with `fastp` or what you're most comfortable with
    ```bash
    mkdir -pv ~/ex6/Cleaned_FastQs
    cd ~/ex6/Cleaned_FastQs
    for read in ~/ex6/Raw_FastQs/*_1.fastq.gz; do
      sample="$(basename ${read} _1.fastq.gz)"
       fastp \
       -i "${read}" \
       -I "${read%_1.fastq.gz}_2.fastq.gz" \
       -o "$HOME/ex6/Cleaned_FastQs/${sample}.R1.fq.gz" \
       -O "$HOME/ex6/Cleaned_FastQs/${sample}.R2.fq.gz" \
       --json "$HOME/ex6/Cleaned_FastQs/${sample}.json" \
       --html "$HOME/ex6/Cleaned_FastQs/${sample}.html"
    done
    ls *.gz
    # Now that you've viewed the system commands this for-loop performs, remove the "echo" and re-run the for-loop to actually perform the read cleaning
    ```

1. Quick assembly with `skesa` as performed previously (e.g., `conda activate ex3`)
    ```bash
    mkdir -pv ~/ex6/Assemblies
    cd ~/ex6/Assemblies
    for read in ~/ex6/Cleaned_FastQs/*.R1.fq.gz; do
      sample="$(basename ${read} .R1.fq.gz)"
      skesa \
       --reads "${read}","${read%R1.fq.gz}R2.fq.gz" \
       --cores 4 \
       --min_contig 1000 \
       --contigs_out ~/ex6/Assemblies/"${sample}".fna
    done
    ls *.fna
    ```

1. Verify filesizes look similar with `ls -alhS *.fna` in your output directory containing all 3 assemblies. If they're not similar in filesizes, refine trim and assembly parameters. All 3 are highly related and in the outbreak.

##### ParSNP
1. Install (note: the `gingr` GUI isn't in bioconda so you'd need to grab the binary for [MacOS Intel](https://github.com/marbl/gingr/releases/download/v1.3/gingr-OSX64-v1.3.app.zip) or [Linux Intel](https://github.com/marbl/gingr/releases/download/v1.3/gingr-Linux64-v1.3.tar.gz) on the repo, or just use `figtree` for the tree-only visualization)
    `conda create -n harvestsuite -c bioconda parsnp harvesttools figtree -y`

1. Parsnp grabs all files in a path, so make a new folder manually or copy symlinks to a new path. This assumes all assemblies are "fa" or "fna" file extensions
    ```bash
    mkdir ~/ex6/parsnp_input_assemblies
    cd ~/ex6/parsnp_input_assemblies
    for file in ~/ex6/Assemblies/*.fna; do
      ln -sv "${file}" "$(basename ${file})"
    done
    ```

1. confirm the 3 files are here and available
    `ls -alhtr *.fna`

1. Run ParSNP with assemblies to generate a core SNP phylogenetic tree. Uses 4 CPUs (-p arg)
    ```bash
    cd ~/ex6
    conda activate harvestsuite
    parsnp \
     -d parsnp_input_assemblies \
     -r ! \
     -o parsnp_outdir \
     -p 4
    ```

1. View phylogenetic tree (a GUI will pop up from this terminal command; or just launch the GUI and open the file)
    `figtree parsnp_outdir/parsnp.tree`

1. Beautify your tree with [InkScape](https://inkscape.org/) or [Adobe Illustrator](https://en.wikipedia.org/wiki/Adobe_Illustrator), save as a usable image-viewing format for future use (e.g., PNG, PDF, SVG)

##### Snippy
1. Install
    `conda create -n snippy -c conda-forge -c bioconda -c defaults snippy iqtree figtree -y`

1. Go into snippy environment where the scripts and binaries for the pipeline are available in your $PATH
    `conda activate snippy`

1. Using the same reference assembly file, identify SNPs for each of the 3 samples. Use [bash string manipulation](https://tldp.org/LDP/abs/html/string-manipulation.html) on the ".R1.fq.gz" to do the loop simpler here with "%" to trim the filename suffix.
    ```bash
    mkdir -pv ~/ex6/snippy_{ref,output}
    cd ~/ex6/snippy_ref
    curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/047/715/GCF_001047715.2_ASM104771v2/GCF_001047715.2_ASM104771v2_genomic.fna.gz
    gunzip *.fna.gz
    conda activate snippy
    for read in $HOME/ex6/Cleaned_FastQs/*.R1.fq.gz; do
      snippy \
      --cpus 4 \
      --outdir ~/ex6/snippy_output/mysnps-"$(basename ${read} .R1.fq.gz)" \
      --ref ~/ex6/snippy_ref/GCF_001047715.2_ASM104771v2_genomic.fna \
      --R1 ${read} \
      --R2 ${read%.R1.fq.gz}.R2.fq.gz
    done
    ```

4. Confirm outfiles for all 3 are present an not empty
    `ls -alhtr ~/ex6/snippy_output/mysnps-*/snps.vcf`

5.  Identify core SNPs among all samples
    ```bash
    snippy-core \
     --prefix  ~/ex6/snippy_output/core \
     --ref ~/ex6/snippy_ref/GCF_001047715.2_ASM104771v2_genomic.fna \
     ~/ex6/snippy_output/mysnps-*
    ```

6. Infer phylogeny
    ```
    iqtree \
     -nt AUTO \
     -st DNA \
     -s ~/ex6/snippy_output/core.aln
    ```

7. View tree
    `figtree ~/ex6/snippy_output/core.aln.treefile`


##### BinDash
1. Install
    `conda create -n bindash -c bioconda bindash -y`

1. Go into the environment where the `bindash` binary will be available to use
    `conda activate bindash`

1. Form a bash array (list of files to be analyzed). This assumes assemblies are "fa" or "fna" file extensions in the current working directory.
    ```bash
    cd ~/ex6/Assemblies
    shopt -s nullglob
    assemblies=( *.{fa,fna} )
    shopt -u nullglob
    ```

1. Perform pairwise comparisons using the store array containing filepaths as input. NOTE: use of bindash is generally not for fine-level comparisons, so you'll need to edit params better or replace with mash for your own group work. Defaults here just show it operates as expected.
    ```bash
    mkdir -pv ~/ex6/bindash
    cd ~/ex6/bindash
    for assembly in ~/ex6/Assemblies/*.fna; do
      bindash \
       sketch \
       --outfname=${assembly}.sketch \
       ${assembly}
    done

    for ((i = 0; i < ${#assemblies[@]}; i++)); do 
      for ((j = i + 1; j < ${#assemblies[@]}; j++)); do 
        echo "${assemblies[i]} and ${assemblies[j]} being compared..."
        sampleA="$(basename ${assemblies[i]} .fna)"
        sampleB="$(basename ${assemblies[j]} .fna)"
        bindash \
         dist \
         ~/ex6/Assemblies/${assemblies[i]}.sketch \
         ~/ex6/Assemblies/${assemblies[j]}.sketch \
         > ~/ex6/bindash/${sampleA}_${sampleB}.tsv
      done
    done 
    ```

5. View values
    `cat ~/ex6/bindash/*.tsv | awk '{print $1, $2, $5}'`

### Homework Assignment
Use all (10) SRA accessions above to fetch the Illumina sequence data from NCBI, and perform 1 of 2 options: `parsnp` or `snippy` approach to evaluate this small outbreak by determining which isolates were part of the outbreak and which are more distant, unrelated to the outbreak.

### Homework Grade Distribution
Upload a single compressed archive file **`comparative.tar.gz`** to Canvas containing:
1. **70%** grade:  a tree image file as `tree.{pdf,png,svg}`
    - 40% all 10 samples labeled in tree
    - 10% scale bar properly labeled
    - 20% aesthetics

1. **20%** grade:  List SRA accessions that were outliers (not truly a part of the outbreak) in plain text format as `outliers.txt`. Empty file means none detected, and multiple lines means multiple outliers.

1. **10%** grade:  `cmds.sh` containing all commands you invoked for this entire project; for WebGUI interactions, record non-default interactions, URLs, and dates used. Please continue to practice commenting!
    - 5% comments
    - 5% commands

- only filenames with exact regex matches will be graded
