# Shared GFF files: [sample]_Prodigal_EggNOG.gff:

## What Are These Files?

The `[sample]_Prodigal_EggNOG.gff` files are bacterial genome annotation files produced by a two-step pipeline:
1. **Prodigal**: Predicts gene locations and coding sequences (structural annotation)
2. **EggNOG-mapper**: Adds functional information to those genes (functional annotation)

These files combine both structural information (where genes are located) and functional information (what those genes do) in a standard GFF3 format.

## How These Files Were Generated

Our pipeline:
1. Runs Prodigal on bacterial genome contigs to predict genes
2. Processes the predicted protein sequences to ensure proper ID formatting
3. Passes those proteins to EggNOG-mapper for functional annotation
4. Integrates the EggNOG annotations back into the Prodigal GFF file

For details: https://github.gatech.edu/compgenomics2025/B2/tree/main/Final_results/Prodigal_EggNOG_Final

## Basic Usage

### Viewing Annotations

These files can be loaded into genome browsers such as:
- **Artemis**: `java -jar artemis.jar [sample]_Prodigal_EggNOG.gff`
- **IGV** (Integrative Genomics Viewer)
- **JBrowse**

### Extracting Information

Extract specific annotations using command-line tools:

```bash
# Get all gene products/functions
grep -Po "product=\K[^;]+" [sample]_Prodigal_EggNOG.gff

# Find genes related to specific pathways
grep "ko00010" [sample]_Prodigal_EggNOG.gff  # Glycolysis pathway
```

### Converting to Other Formats

Convert to GenBank format if needed:
```bash
gff2gbk.py -i [sample]_Prodigal_EggNOG.gff -f [sample]_contigs.fa -o [sample].gbk
```

## Key Information in These Files

The GFF3 files contain rich annotation data in the 9th column (attributes), including:
- Gene ID and location information
- Protein product descriptions
- GO terms for function
- EC numbers for enzymatic activity
- KEGG pathways and orthologs
- Protein family classifications

## Recommended Applications

These annotation files are useful for:
- Identifying gene functions in your bacterial genomes
- Metabolic pathway reconstruction
- Comparative genomic analyses
- Finding specific gene families or functional categories
- Understanding the functional potential of your bacterial strains

