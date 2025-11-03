# Setup
To run the pipeline, you require the following tools: GeMomA, Prodigal, barrnap, Eggnog, and InterPro. For installing the first four, you can simply set up a conda environment as follows.

```bash
conda create -n pipeline_env -y
conda activate pipeline_env
conda install -c bioconda -c conda-forge gemoma -y
conda install -c bioconda -c conda-forge prodigal -y
conda install -c bioconda -c conda-forge barrnap -y
conda install -c conda-forge eggnog-mapper -y
```

Additionally, you may have to install the correct Python version as necessary.

```bash
conda install "python==3.11.9" -y
```

If you are running into trouble with dependencies, use the versions specified on the main readme for the pipeline results or use the conda environment yml in this directory as follows where {user} is your username and {env_name} is the desired environment name:

```bash
conda env create -f pipeline_env.yml -p /home/{user}/miniforge3/envs/{env_name}
```

If you run into solver issues you might have to set your channel priority to flexible:

```bash
conda config --set channel_priority flexible
```

Next, you might need to download the eggnog db, which can be done by calling:

```bash
download_eggnog_data.py
```

Review [eggnog's githubb](https://github.com/eggnogdb/eggnog-mapper) for more specific instructions.

For installing interpro, please review the [interpro docs](https://interproscan-docs.readthedocs.io/en/v5/) as the setup process can be a bit challenging.

Finally, be sure to make the script executable:

```bash
chmod +x gene_prediction_and_annotation.py
```



