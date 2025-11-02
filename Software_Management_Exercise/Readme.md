## Specific Learning Objectives
1. create new conda environments by connecting to online/external repository sources
1. install packages within conda environment
1. export/store single file listing all software versions within a conda environment
1. create new conda environments from a locally stored/archived file


## General Installation of Conda
- If you have a working `conda` already, you're welcome to use it.
- If you lack conda, installation process depends on the operating system. Note, the mostly widely use channel "bioconda" does not support Windows, so in Windows you'll want to install and [use WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) to get a Linux OS such as Ubuntu.


##### Install Conda
- Hardware:
  - If you don't know what type of CPU chip you have, you can type `uname -m` in the terminal prompt
    - `arm64` is Apple Silicon (e.g., M1, M2, M3, or M4 chip)
    - `x86_64` is AMD or Intel with 64 bits
  - Many bioinformatics software packages require you know which kind of CPU you have, whereas common graphical software often auto-detect and choose the proper one.

- Recommended:
  - miniforge3 [src](https://github.com/conda-forge/miniforge) [tutorial](https://ubinfie.github.io/2024/10/15/anaconda-defaults.html)
  - For **Ubuntu 24.04 LTS** with **Intel** chip and `echo $SHELL` being **bash**:
    ```bash
    cd ~/Downloads
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    chmod u+x Miniforge*.sh
    ./Miniforge3-Linux-x86_64.sh
        # ENTER
        # I saved mine installation in non-default to hide "/home/cg/.miniforge3" but default is okay too
        # "yes" to `conda init --reverse $SHELL`? [yes|no]
    . ~/.bashrc
    which conda
        # /home/cg/.miniforge3/bin/conda
    conda --version
        # conda 24.11.2
    conda --help
        # full help menu should print
    conda config --add channels r
    conda config --add channels conda-forge
    conda config --add channels bioconda
    conda config --set channel_priority strict
    ```

  - For **MacOS** with **Intel** chip and `echo $SHELL` being **bash**:
    ```bash
    cd ~/Downloads
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    chmod u+x Miniforge*.sh
    ./Miniforge3-Darwin-x86_64.sh
        # ENTER
        # I saved mine installation in non-default to hide "/Users/cg/.miniforge3_intel" but default is okay too
        # "yes" to `conda init --reverse $SHELL`? [yes|no]
    . ~/.bashrc
    which conda
        # /Users/cg/.miniforge3_intel/bin/conda
    conda --version
        # conda 24.11.2
    conda --help
        # full help menu should print
    conda config --add channels r
    conda config --add channels conda-forge
    conda config --add channels bioconda
    conda config --set channel_priority strict
    ```

  - For **MacOS** with an M2 (**ARM64**) chip and `echo $SHELL` being **zsh**:
    ```zsh
    cd ~/Downloads
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    chmod u+x Miniforge*.sh
    ./Miniforge3-Darwin-arm64.sh
        # ENTER
        # I saved mine installation in non-default to hide "/Users/cg/.miniforge3_arm64" but default is okay too
        # "yes" to `conda init --reverse $SHELL`? [yes|no]
    . ~/.zshrc
    which conda
        # conda () {
        #	\local cmd="${1-__missing__}"
        #	 case "$cmd" in
        #	 	(activate | deactivate) __conda_activate "$@" ;;
        #	 	(install | update | upgrade | remove | uninstall) __conda_exe "$@" || \return
        #	 		__conda_activate reactivate ;;
        #	 	(*) __conda_exe "$@" ;;
        #	 esac
        # }
    which -p conda
        # /Users/cg/.miniforge3_arm64/bin/conda  ## NOTE: zsh needs the '-p' whereas bash doesn't to print the absolute path
    conda --version
        # conda 24.11.2
    conda --help
        # full help menu should print
    conda config --add channels r
    conda config --add channels conda-forge
    conda config --add channels bioconda
    conda config --set channel_priority strict
    ```

- Other Options:
  - Anaconda [download](https://www.anaconda.com/download#downloads): the commercial entity behind the conda, miniconda, and the Anaconda.Navigator software suite
    - Choose Anaconda if you want a **comprehensive**, out-of-the-box solution with a wide range of pre-installed packages. It's *ideal for beginners* and those who want to explore different packages without worrying about manual installation. Be **very cautious and understand** the [terms of service](https://legal.anaconda.com/policies/en/?name=terms-of-service#anaconda-terms-of-service) before installing.
  - miniconda [download](https://docs.conda.io/projects/conda/en/stable/)
    - Choose Miniconda if you prefer a **minimal**, lightweight solution. It's *great for experienced users* who know exactly what packages they need and want to maintain a clean, clutter-free environment.


##### Cheatsheet
- Save, print double-sided, and use this [PDF](https://docs.conda.io/projects/conda/en/stable/user-guide/cheatsheet.html) cheatsheet of common tasks and commands


##### Simple "sm" conda environment
1. Create a conda environment named "sm". With no specified software yet, this should be quick to make and empty of new software.
`conda create -n sm -y`


2. Go into the "sm" environment, install the pigz utility from the conda-forge channel, and test it out.
    ```
    conda activate sm
    conda install -c conda-forge pigz -y
    echo '[BIOL7210]' > stdout.txt
    pigz stdout.txt
    zcat stdout.txt.gz
    conda env export > my_simple_pigz_conda_environment.yml
    conda deactivate
    ```
- If you do not see "[BIOL7210]", **don't proceed** until you resolve the issue
- Now if you want to create that enviroment in the future, all you need is that YAML file and can re-create the whole environment again. Note your environment name "sm" is at the top of the file, so if you want to change from "sm" into a new name, edit that first. `conda env create -f environment.yml`


3. Create a general conda environment for using older Python 2.7.+ scripts with common bioinformatics libraries
    - NOTE: channel order prioritizes bioconda (should be top of your `~/.condarc` file) but falls back to conda-forge (lower in priority)
    - NOTE: Mac's NumPy/Pandas errors often stem from missing libopenblas, so try `conda install -c conda-forge openblas` if you have install issues.
    ```
    conda create -n bpy2 -y
    conda activate bpy2
    conda install -c bioconda -c conda-forge python=2.7 biopython numpy pandas matplotlib seaborn -y
    ```
- TIP:  If it fails to solve the environment install, try relaxing version numbers.
    - This is also where the `mamba` solver (quick) shows its strength in speed to solve installations. Install mamba easily with `conda install mamba -y`, then use `mamba` instead of conda for the install command.


#### Learn to compress a full directory
1. make several directories
`mkdir -pv dir{1,2,3}/subdir{A,B}`
    - Using [brace expansion](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html) isn't just shorter to type, it prevents typo errors (e.g., dir1,dri2,dir3).
        - Renaming files is easy with `mv file.log file.log.bak` but what if you make a typo like `mv file.log flie.log.bak`? Especially when moving it as a backup file, this is better `mv file.log{"",.bak}` to avoid that issue.
1. view what you made with `tree`
    ```bash
    .
    ├── dir1
    │   ├── subdirA
    │   └── subdirB
    ├── dir2
    │   ├── subdirA
    │   └── subdirB
    └── dir3
        ├── subdirA
        └── subdirB
    ```
3. archive and compress the whole directory structure into a small single file
`tar -czvf single-archive-compressed.tar.gz dir{1,2,3}`
4. view the newly created filesize
`ls -lh single-archive-compressed.tar.gz`
    - about 187 bytes in size


## Homework
1. Store **all commands** (line-by-line) to install and generate the submission file as a single 'cmds.sh' file (excluding the final archiving and compression tar.gz file formation command)
1. Create a new conda environment with [FastANI](https://bioconda.github.io/recipes/fastani/README.html#package-fastani) in it, and generate a dependency yaml of it as 'environment_fastani.yml'
    - NOTE: if you get an error "error while loading shared libraries: libgsl.so.25", you'll likely need to install `-c conda-forge gsl` to get those GSL C++ header files
    - view its help menu and version number `fastANI --help` and `fastANI --version`
      - version 1.34 is what I have installed
1. Within the same conda environment with only FastANI installed, also install [fasten](https://bioconda.github.io/recipes/fasten/README.html#package-fasten), and store the full environment's dependency yaml as 'environment_fastani_fasten.yml'
    - NOTE: fasten itself is not a binary, it contains many `fasten_<suffix>` binaries, such as `fasten_clean`.
    - view its help menu and version number `fasten_clean --help` and `fasten_clean --version`
      - Fasten v0.8.4 is what I have installed
1. Within the same conda environment with only FastANI and fasten installed, also install [pandas](https://anaconda.org/conda-forge/pandas), and store its dependency as 'environment_fastani_fasten_pandas.yml'
    - pandas help menu is online [here](https://pandas.pydata.org/docs/) but you can view all public objects with `python -c "import pandas as pd; print(pd.__all__)"` and its version number with `python -c "import pandas as pd; print(pd.__version__)"`
      - 2.2.3 is the pandas version I have installed
1. Create a `versions.txt` file listing all 3 main package version numbers using their built-in version printing. Remember a single ">" (e.g., `fastANI --version > file.txt`) overwrites a file and puts only that new command's information. Appending to the same file in a subsequent command requires ">>" (e.g., `fastANI --version >> file.txt`).
1. form a single gunzipped tarball containing:
    - all 3 YAML files, 
    - versions.txt, and 
    - cmds.sh


## Homework Grade Distribution
- 85% grade:  upload (compressed) `intro_conda_environments.tar.gz`, containing:
    - 25% grade:  `environment_fastani.yml`
    - 20% grade:  `environment_fastani_fasten.yml`
    - 20% grade:  `environment_fastani_fasten_pandas.yml`
    - 20% grade:  `versions.txt`
        - 10% grade:  fastani version number
        -  5% grade:  fasten version number
        -  5% grade:  pandas version number
- 15% grade:  upload `cmds.sh` containing all commands you invoked for this entire project; practice commenting!
    - 5% grade for each complete environment description
- only filenames with *exact* regex matches will be graded
