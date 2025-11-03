# Examples

Note for all of the example commands, the file paths given are samples and must be changed depending on your file structure. Please refer to `parameters.md` for more information on which parameters require user file input.

## Basic Usage

Here are four example commands to show the basics of the workflow for each (main) possible workflow. 

```bash
./gene_annotation_and_prediction -i ./data/*.fa -p -pd -ip -isp ./interproscan-5.73-104.0/interproscan.sh -ad
```
This will run prodigal gene prediction and interpro annotation for the given input files with the default parameters.

```bash
./gene_annotation_and_prediction -i ./data/*.fa -p -pd -eg -ed ./eggnog_data -ad
```
This will run prodigal gene prediction and eggnog annotation for the given input files with the default parameters.

```bash
./gene_annotation_and_prediction -i ./data/*.fa -g -gr ./data/reference.fna -ga ./data/reference.gff -pd -ip -isp ./interproscan-5.73-104.0/interproscan.sh -ad
```
This will run gemoma gene prediction and interpro annotation for the given input files with the default parameters.

```bash
./gene_annotation_and_prediction -i ./data/*.fa -g -gr ./data/reference.fna -ga ./data/reference.gff -pd -eg -ed ./eggnog_data -ad
```
This will run gemoma gene prediction and eggnog annotation for the given input files with the default parameters.


## Intermediate Usage

These commands show some additional parameters recommended to speed up computation or allow for more user control. 

```bash
./gene_annotation_and_prediction  -i ./data/*.fa -g -gr -t 24 ./data/reference.fna -ga ./data/reference.gff -pd -eg -ed ./eggnog_data -ad
```

This will run gemoma gene prediction and eggnog annotation for the given input files with the default parameters, but additionally uses the threads argument to massively speed up computation as gemoma and eggnog benefit greatly from parallelization. 

```bash
./gene_annotation_and_prediction -i ./data/*.fa -p -pl ./pred_logs -po ./pred_outputs -pm ./pred_metrics -pmn Pred_Metrics -pd -ip -isp ./interproscan-5.73-104.0/interproscan.sh -ad
```
This will run prodigal gene prediction and interpro annotation for the given input files with the default parameters but additionally uses the -pl, -po, and -pm to specify output directories for the logs, outputs, and metrics along with specifying the name of the metrics file with -pmn.

```bash
./gene_annotation_and_prediction -i ./data/*.fa -g -gr ./data/reference.fna -ga ./data/reference.gff -pd -op
```

This will run gemome prediction with default parameters, but no annotation as specified by -op(only prediction).

```bash
./gene_annotation_and_prediction  -i ./data/*.fa -g -gr -t 24 -r ./data/reference.fna -ga ./data/reference.gff -pd -eg -ed ./eggnog_data -ad
```

This will run gemoma gene prediction and eggnog annotation for the given input files with the default parameters, but additionally uses the threads argument to massively speed up computation as gemoma and eggnog benefit greatly from parallelization along with specifying -r to also do RNA prediction.


## Advanced Usage

These commands show how to use the parameter arguments to customize the prediction and annotation.

```bash
./gene_annotation_and_prediction -i ./data/*.fa -p -pp "-m" -ip -isp ./interproscan-5.73-104.0/interproscan.sh -ad
```
This will run prodigal gene prediction and interpro annotation for the given input files with the default parameter for interpro, but specifying -m for prodigal which controls gap handling behavior.

```bash
./gene_annotation_and_prediction  -i ./data/*.fa -g -gr -t 24 -r ./data/reference.fna -ga ./data/reference.gff -pd -eg -ed -ep "--tax_scope Gammaproteobacteria --go_evidence experimental" ./eggnog_data
```

This will run gemoma gene prediction and eggnog annotation for the given input files with the default parameters, but additionally uses the threads argument to massively speed up computation as gemoma and eggnog benefit greatly from parallelization along with specifying -r to also do RNA prediction. However, this will also run eggnog with the taxonomic scope of "Gammaproteobacteria" for annotations and only use GO terms that are inferred from experimental evidence.



