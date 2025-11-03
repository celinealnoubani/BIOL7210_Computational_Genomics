# Final Pipeline
This directory contains the final pipeline script along with documentation indicating how to effectively use this final pipeline script to produce results via gene prediction and annotation.

# System Specifications
The following OS and hardware was used to develop the pipeline:
- Architecture: x86_64 (AMD64)
- CPU: Ryzen 9 7900X (12 Cores, 24 Threads)
- Memory: 64 GB DDR5 CL30 6000 MT/S
- Operating System: Ubuntu 22.04.3 LTS  (5.15.167.4-microsoft-standard-WSL2)

# Tools Used
- Python: 3.11.9
- GeMoMA: 1.7.1
- Prodigal: V2.6.3
- barrnap: 0.9
- Eggnog: emapper-2.1.12, eggnog DB: 5.0.2
- InterPro: 5.73-104.0

# Important Notes
This script contains a pipeline that runs gene prediction and annotation pipeline using prodigal/gemoma(+ barrnap for rRNA gene prediction) for gene prediction and interpro/eggnog for annotation. Users must have an appropriately set up conda environment to run this script and have the interpro and eggnog db locally stored. Details for environment setup and db information can be found in `Documentation/setup.md`. Furthermore, full descriptions of parameters can be found in `Documentation/parameters.md`. Moreover, example usage can be found in `Documentation/examples.md`. Finally, to produce the results we have obtained, use the final contigs data as input to the script and utilize the default parameter flags for the script for each of the workflows, see `Documentation/parameters.md` and `Documentation/examples.md` for the parameters and examples to use to specifically produce the results. Furthermore, log files for the final files are located in the final results directory for each tool according to their individual workflows. For information on how log files are stored for this script, check `Documentation/parameters.md` for log related arguments.

# File Structure
- `gene_prediction_and_annotation.py`: Final pipeline script that can run gene prediction and annotation in one line
- `Documentation/*`: Setup, Parameter, and Example documentation files + .yml file for a conda environment with all packages installed + a png image showing the parameters for the script

