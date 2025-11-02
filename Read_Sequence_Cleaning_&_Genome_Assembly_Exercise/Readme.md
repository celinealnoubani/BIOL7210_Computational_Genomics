## Specific Learning Objectives
1. fetch raw FastQ data from NCBI
1. quickly assess read quality
1. use a read cleaning tool that does some (but not all) sequence filtering/removal
1. quickly assemble an isolate genome
1. identify the value of post-process filtering of a raw assembly


##### Create conda environment with software for this exercise
`conda create -n ex3 -y`


##### Go into the ex3 environment and install a bunch of utilities from the bioconda channel
```
conda activate ex3
conda install -c bioconda -c conda-forge entrez-direct sra-tools fastqc trimmomatic skesa spades pigz tree -y
```
- NOTE: as of _21-JAN-2025_, `sra-tools` and `skesa` are not supported in bioconda for ARM64 chips, so you'll get an install error that can be resolved by removing those two: `conda install -c bioconda -c conda-forge entrez-direct fastqc trimmomatic spades pigz tree -y`
  - The `sra-tools` bundle (which includes `fasterq-dump` can be manually downloaded [here](https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit#sra-toolkit) for [ARM64 chips](https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.2.0/sratoolkit.3.2.0-mac-arm64.tar.gz), and ran after [MacOS Gatekeeper allows it to Open](https://support.apple.com/guide/mac-help/apple-cant-check-app-for-malicious-software-mchleab3a043/mac) with `~/Downloads/sratoolkit.3.2.0-mac-arm64/bin/fasterq-dump --version` which printed v3.2.0 for me. [SKESA src compiling](https://github.com/ncbi/SKESA?tab=readme-ov-file#compilation) relies on Boost C++ Libraries, which is especially challenging to compile from src with Darwin ARM64. It is unavailable in `brew` too, but GitPod is an alternative.
 
  - Another solution for students with ARM64 MacOS platforms would be to install Rosetta 2 provided by Apple, instructions can be found [here](https://support.apple.com/en-us/102527). This allows the emulation of x86 apps on the ARM64 architecture (this also will be helpful for other tools).
  - Once Rosetta 2 is installed, the conda environment creation requires the following change:
  ```
  CONDA_SUBDIR=osx-64 conda create -n ex3 -y
  ```
  - This allows Conda to emulate the osx-64 platform and will look for packages in platform specific channels, something that is hidden by default and controlled by the type of architecture that conda detects. With this, you can simply run the conda install command given above and install the tools without any issues.

##### Fetch FastQ data
- For conda-installed sra-tools (**Intel** chips)
```bash
mkdir -pv ~/exercise_3/raw_data
cd ~/exercise_3/raw_data
fasterq-dump --version     # mine was fasterq-dump : 3.1.1
fasterq-dump \
 SRR15276224 \
 --outdir ~/exercise_3/raw_data \
 --split-files \
 --skip-technical
du -sh ~/exercise_3/raw_data/*.fastq
    # 173M : SRR15276224_1.fastq
    # 173M : SRR15276224_2.fastq
pigz -9fv ~/exercise_3/raw_data/*.fastq
tree -ah ~/exercise_3
    # [  96]  exercise_3
    # └── [ 128]  raw_data
    #     ├── [ 46M]  SRR15276224_1.fastq.gz
    #     └── [ 49M]  SRR15276224_2.fastq.gz
```

- For **ARM64** manually downloaded sra-tools (ARM64 chips). Note: the `fasterq-dump` gave an error for me, but the `fastq-dump` still worked. Fortunately NCBI used identical arguments for what we need, so it's only the binary name that changes.
```zsh
mkdir -pv ~/exercise_3/raw_data
cd ~/exercise_3/raw_data
~/Downloads/sratoolkit.3.2.0-mac-arm64/bin/fastq-dump --version     # mine was v3.2.0
~/Downloads/sratoolkit.3.2.0-mac-arm64/bin/fastq-dump \
 SRR15276224 \
 --outdir ~/exercise_3/raw_data \
 --split-files \
 --skip-technical
du -sh ~/exercise_3/raw_data/*.fastq
    # 173M : SRR15276224_1.fastq
    # 173M : SRR15276224_2.fastq
pigz -9fv ~/exercise_3/raw_data/*.fastq
tree -ah ~/exercise_3
    # [  96]  exercise_3
    # └── [ 128]  raw_data
    #     ├── [ 46M]  SRR15276224_1.fastq.gz
    #     └── [ 49M]  SRR15276224_2.fastq.gz
```
- backup webpage GUI download option https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR15276224&display=download select "FastQ" format to download
- **NOTE**: *never* store FastQ uncompressed!

-If fasterq-dump is not working and is exiting with an error code 3: the solution would be to run prefetch first to pull the SRA dependencies and then run fasterq-dump. 

```bash
prefetch SRR15276224
fasterq-dump SRR15276224 --outdir ~/exercise3/raw_data --split-files --skip-technical
```

#### View quality assessment
```
mkdir -v ~/exercise_3/raw_qa
fastqc --version    # mine was FastQC v0.12.1
fastqc \
 --threads 2 \
 --outdir ~/exercise_3/raw_qa \
 ~/exercise_3/raw_data/SRR15276224_1.fastq.gz \
 ~/exercise_3/raw_data/SRR15276224_2.fastq.gz
tree -ah ~/exercise_3
      #  [ 128]  /Users/agulvik/exercise_3
      #  ├── [ 128]  raw_data
      #  │   ├── [ 46M]  SRR15276224_1.fastq.gz
      #  │   └── [ 49M]  SRR15276224_2.fastq.gz
      #  └── [ 192]  raw_qa
      #      ├── [658K]  SRR15276224_1_fastqc.html
      #      ├── [454K]  SRR15276224_1_fastqc.zip
      #      ├── [661K]  SRR15276224_2_fastqc.html
      #      └── [461K]  SRR15276224_2_fastqc.zip
google-chrome ~/exercise_3/raw_qa/*.html
firefox ~/exercise_3/raw_qa/*.html
```


#### Remove low quality reads
```bash
mkdir -v ~/exercise_3/trim
cd ~/exercise_3/trim
trimmomatic -version     # mine was 0.39
trimmomatic PE -phred33 \
 ~/exercise_3/raw_data/SRR15276224_1.fastq.gz \
 ~/exercise_3/raw_data/SRR15276224_2.fastq.gz \
 ~/exercise_3/trim/r1.paired.fq.gz \
 ~/exercise_3/trim/r1_unpaired.fq.gz \
 ~/exercise_3/trim/r2.paired.fq.gz \
 ~/exercise_3/trim/r2_unpaired.fq.gz \
 SLIDINGWINDOW:5:30 AVGQUAL:30 \
 1> trimmo.stdout.log \
 2> trimmo.stderr.log
cat ~/exercise_3/trim/r1_unpaired.fq.gz \
 ~/exercise_3/trim/r2_unpaired.fq.gz \
 > ~/exercise_3/trim/singletons.fq.gz
rm -v ~/exercise_3/trim/*unpaired*
tree -ah ~/exercise_3/trim
    #    [4.0K]  /home/$USER/exercise_3/trim
    #    ├── [ 31M]  r1.paired.fq.gz
    #    ├── [ 31M]  r2.paired.fq.gz
    #    ├── [6.4M]  singletons.fq.gz
    #    ├── [ 620]  trimmo.stderr.log
    #    └── [   0]  trimmo.stdout.log
    #
    #    1 directory, 5 files
```

#### Assemble with SPAdes
```bash
mkdir -v ~/exercise_3/asm
cd ~/exercise_3/asm
spades.py --version     # mine was v4.0.0
spades.py \
 -1 ~/exercise_3/trim/r1.paired.fq.gz \
 -2 ~/exercise_3/trim/r2.paired.fq.gz \
 -s ~/exercise_3/trim/singletons.fq.gz \
 -o ~/exercise_3/asm/spades \
 --only-assembler \
 1> spades.stdout.txt \
 2> spades.stderr.txt
```
- view how many contigs
```
grep -c '>' ~/exercise_3/asm/spades/contigs.fasta
    # mine had 101 contigs
```

#### Assemble with SKESA
```bash
mkdir -v ~/exercise_3/asm
cd ~/exercise_3/asm
skesa --version     # mine was SKESA 2.5.1
skesa \
 --reads ~/exercise_3/trim/r1.paired.fq.gz ~/exercise_3/trim/r2.paired.fq.gz \
 --contigs_out ~/exercise_3/asm/skesa_assembly.fna \
 1> skesa.stdout.txt \
 2> skesa.stderr.txt
```
- view how many contigs
```
grep -c '>' *.fna
    # mine had 28 contigs
```


#### Homework
1. fetch [SRR28480439](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&page_size=10&acc=SRR28480439&display=metadata) Illumina PE FastQ R1 and R2 files from the recent (Jan 2025) publication ["Draft genome sequences of Corynebacterium mastitidis strains isolated from ocular surface of CD36-knockout mice (B6.129S1-Cd36tm1Mfe/J) with keratitis"](https://journals.asm.org/doi/10.1128/mra.00562-24), where they report 55 contigs and 2,208,133 bp assembly size at 149.7x mean depth
1. quality trim (consider additional options not used in first example)
1. assemble with SPAdes
1. use [filter.contigs.py](https://github.com/bacterial-genomics/genomics_scripts/blob/main/filter.contigs.py) (you'll need Python v2.7 with Biopython installed in a conda environment) to evaluate how filtering parameters (e.g., contig coverage, contig length, etc.) affect your output genome size. For example,
    ```
    conda install python=2.7 biopython -y
    curl -O https://raw.githubusercontent.com/bacterial-genomics/genomics_scripts/refs/heads/main/filter.contigs.py
    chmod u+x *.py
    ./filter.contigs.py --infile asm/spades/contigs.fasta --outfile filtered-contigs.fa --discarded removed-contigs.fa 1> contig-filtering.stdout.log 2> contig-filtering.stderr.log
    tail -n 20 contig-filtering.stderr.log
    ```
    - Decide which parameters seem reasonable to use to form a higher quality output assembly file that represents the isolate's genome. Save output FastA file as `filtered_assembly.fna` Include your commands in upload.
1. Upload a single compressed archive file **`assembly.tar.gz`** containing:
    - **70%** grade:  upload (compressed) `filtered_assembly.fna.gz`
    - **15%** grade:  upload `cmds.sh` containing all commands you invoked for this entire project; practice commenting what you did with "# comment info" lines!
    - **15%** grade:  upload SPAdes logfile (compressed) `spades.log.gz`
- only filenames with *exact* regex matches will be graded
