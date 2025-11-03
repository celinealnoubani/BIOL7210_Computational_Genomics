#!/usr/bin/env python3

#imports
import argparse
import sys
import subprocess
import tempfile

def set_args() -> argparse.ArgumentParser:
    '''Sets up the arguments for the pipeline script

    Args:
        None

    Returns:
        An Argument Parser object with the necessary arguments for the pipeline
    '''

    #Initializes the argparse object and sets the description
    pipeline = argparse.ArgumentParser(description="Runs gene prediction and annotation pipeline using prodigal/gemoma(+ barrnap for rRNA gene prediction) for gene prediction and interpro/eggnog for annotation")
    
    #Adds the prodigal argument
    pipeline.add_argument(
    "-p", 
    help="Use prodigal for gene prediction",
    dest = "Prodigal",
    required=False,
    action = "store_true"
    )
    
    #Adds the gemoma argument
    pipeline.add_argument(
    "-g", 
    help="Use gemoma for gene prediction",
    dest="Gemoma",
    required=False,
    action = "store_true"
    )

    #Adds the Input argument
    pipeline.add_argument(
    "-i", 
    help="input contig assembly file(s)",
    dest="Input",
    required=True,
    nargs = '*'
    )
    
    #Adds the Compressed argument
    pipeline.add_argument(
    "-c", 
    help="Indicates input files are compressed (.gz)",
    dest="Compressed",
    required=False,
    action = "store_true"
    )
    

    #Adds the Pred_logs argument
    pipeline.add_argument(
    "-pl", 
    help="Prediction logs directory",
    dest="Pred_Logs",
    required=False,
    type = str
    )

    #Adds the Pred_Output argument
    pipeline.add_argument(
    "-po", 
    help="Prediction output (gff files + aa translations) directory",
    dest="Pred_Output",
    required=False,
    type = str
    )

    #Adds the Pred_Metrics argument
    pipeline.add_argument(
    "-pm", 
    help="Prediction metrics output directory",
    dest="Pred_Metrics",
    required=False,
    type = str
    )

    #Adds the (Prediction) Metric_Name argument
    pipeline.add_argument(
    "-pmn", 
    help="Prediction Metric File Name (String not path with no extension)",
    dest="Metric_Name",
    required=False,
    default = "Prediction_Metrics",
    nargs = "?",
    type=str
    )

    #Adds the Pred_Default argument
    pipeline.add_argument(
    "-pd", 
    help="Use Default Prediction Parameters",
    dest="Pred_Default",
    required=False,
    action = "store_true"
    )

    pipeline.add_argument(
    "-pp", 
    help="Prodigal parameters (String containing prodigal arguments)",
    dest="Prodigal_Parameters",
    required=False,
    type=str
    )

    #Adds the Gemoma_parameters argument
    pipeline.add_argument(
    "-gp", 
    help="Gemoma parameters (String containing gemoma arguments)",
    dest="Gemoma_parameters",
    required=False,
    type=str
    )

    #Adds the Gemoma_Ref argument
    pipeline.add_argument(
    "-gr", 
    help="Path to ref genoma (fna) for gemoma",
    dest="Gemoma_Ref",
    required=False,
    type=str
    )

    #Adds the Gemoma_Ann argument
    pipeline.add_argument(
    "-ga", 
    help="Path to ref annotation (gff) for gemoma",
    dest="Gemoma_Ann",
    required=False,
    type=str
    )

    #Adds the Threads argument
    pipeline.add_argument(
    "-t", 
    help="(CPU) Threads for all multithreaded tools",
    dest="Threads",
    required=False,
    nargs = "?",
    default = 8,
    type=int
    )

    #Adds the RNA argument
    pipeline.add_argument(
    "-r", 
    help="Do 16S rRNA prediction via barrnap",
    dest="RNA",
    required=False,
    action = "store_true"
    )

    #Adds the rRNA_Parameters argument
    pipeline.add_argument(
    "-rp", 
    help="16S rRNA parameters",
    dest="rRNA_Parameters",
    required=False,
    type=str
    )

    #Adds the InterPro argument
    pipeline.add_argument(
    "-ip",
    help="Use InterPro for annotation",
    dest="InterPro",
    required=False,
    action="store_true"
    )

    #Adds the InterPro_Script argument
    pipeline.add_argument(
    "-isp",
    help="Path to interpro install(location of interpro.sh script + other intepro files)",
    dest="InterPro_Script",
    required=False,
    type=str
    )

    #Adds the Eggnog argument
    pipeline.add_argument(
    "-eg",
    help="Use eggnog for annotation",
    dest="Eggnog",
    required=False,
    action="store_true"
    )

    #Adds the Eggnog_DB argument
    pipeline.add_argument(
    "-ed",
    help="Path to eggnog data dir(eggnog database directory)",
    dest="Eggnog_DB",
    required=False,
    type=str
    )


    #Adds the Ann_Default argument
    pipeline.add_argument(
    "-ad",
    help="Use default annotation parameters",
    dest="Ann_Default",
    required=False,
    action="store_true"
    )

    #Adds the InterPro_Parameters argument
    pipeline.add_argument(
    "-ipp",
    help="InterPro Parameters (String containing InterPro arguments)",
    dest="InterPro_Parameters",
    required=False,
    type=str
    )

    #Adds the Eggnog_Parameters argument
    pipeline.add_argument(
    "-ep",
    help="Eggnog Parameters (String containing Eggnog arguments)",
    dest="Eggnog_Parameters",
    required=False,
    type=str
    )

    #Adds the Ann_Logs argument
    pipeline.add_argument(
    "-al", 
    help="Annotation logs directory",
    dest="Ann_Logs",
    required=False,
    type = str
    )

    #Adds the Ann_Output argument
    pipeline.add_argument(
    "-ao", 
    help="Annotation output (annotated gff files) directory",
    dest="Ann_Output",
    required=False,
    type = str
    )

    #Adds the Ann_Metrics argument
    pipeline.add_argument(
    "-am", 
    help="Annotation metrics output directory",
    dest="Ann_Metrics",
    required=False,
    type = str
    )

    #Adds the Annotation_Metrics argument
    pipeline.add_argument(
    "-amn", 
    help="Annotation Metric File Name (String not path with no extension)",
    dest="Ann_Metric_Name",
    required=False,
    default = "Annotation_Metrics",
    nargs = "?",
    type=str
    )

    #Adds the Only_Prediction argument
    pipeline.add_argument(
    "-op",
    help="Only do gene prediction",
    dest="Only_Prediction",
    required=False,
    action="store_true"
    )
    


    #Returns the Argument Parser object
    return(pipeline)

def prodigal_prediction(Input, Log_Dir, Output_Dir, Metrics_Dir, Default, Params, Metric_Name):
    """
    Runs gene prediction via prodigal

    Args:
        Input: list of strings containing file paths to assemblies
        Log_Dir: string of path to log directory
        Output_Dir: string of path to prediction output directory
        Metrics_Dir: string of path to metric directory
        Default: boolean indicating whether to use default prodigal parameters
        Params: string of prodigal parameters
        Metric_Name: string containing the name of the prediction metric summary file         

    Returns:
        tuple containing two lists: first faa file list, second gff file list
    """

    #Return lists
    Gff_files = []
    Faa_files = []

    #If default run prodigal with default params else use user input params
    if (Default):

        #for each assembly in input run prodigal with default parameters
        for file in Input:

            #get sample name from file
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #run prodigal
            command = f"prodigal -i {file} -o {Output_Dir}/{output_str}_prodigal.gff -f gff -a {Output_Dir}/{output_str}_prodigal.faa -m -c 2> {Log_Dir}/{output_str}_log.txt"
            subprocess.run(command, shell = True)

            #record output file strings to lists
            Gff_files.append(f"{Output_Dir}/{output_str}_prodigal.gff")
            Faa_files.append(f"{Output_Dir}/{output_str}_prodigal.faa")
    else:

        #for each assembly in input run prodigal with user input parameters
        for file in Input:

            #get sample name from file
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #run prodigal
            command = f"prodigal -i {file} -o {Output_Dir}/{output_str}_prodigal.gff -f gff -a {Output_Dir}/{output_str}_prodigal.faa "
            command += Params
            command += f" 2> {Log_Dir}/{output_str}_log.txt"
            subprocess.run(command, shell = True)

            #record output file strings to lists
            Gff_files.append(f"{Output_Dir}/{output_str}_prodigal.gff")
            Faa_files.append(f"{Output_Dir}/{output_str}_prodigal.faa")

    #gets prediction metrics
    gene_prediction_metrics(Metrics_Dir, Gff_files, Metric_Name)

    #returns file lists
    return (Faa_files, Gff_files)

        
        
def gemoma_prediction(Input, Log_Dir, Output_Dir, Metrics_Dir, Default, Params, Ref, Ann, Threads, Metric_Name):
    """
    Runs gene prediction via gemoma

    Args:
        Input: list of strings containing file paths to assemblies
        Log_Dir: string of path to log directory
        Output_Dir: string of path to prediction output directory
        Metrics_Dir: string of path to metric directory
        Default: boolean indicating whether to use default gemoma parameters
        Params: string of gemoma parameters
        Ref: string of path to reference genome
        Ann: string of path to reference annotation
        Threads: number of cpu threads
        Metric_Name: string containing the name of the prediction metric summary file         

    Returns:
        tuple containing two lists: first faa file list, second gff file list
    """

    #Return lists
    Gff_files = []
    Faa_files = []

    #If default run gemoma with default params else use user input params
    if (Default):

        #run gemoma for each assembly in input
        for file in Input:

            #gets sample name
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #runs gemoma
            command = f"GeMoMa GeMoMaPipeline threads={Threads} outdir={Output_Dir} GeMoMa.Score=ReAlign AnnotationFinalizer.r=NO o=true t={file} i=1 a={Ann} g={Ref} >{Log_Dir}/{output_str}_gemoma_stdout.txt 2> {Log_Dir}/{output_str}_gemoma_stderr.txt"
            subprocess.run(command, shell = True)

            #renames outputs to more meaningful names
            command = f"mv {Output_Dir}/final_*.gff {Output_Dir}/{output_str}_gemoma.gff"
            subprocess.run(command, shell = True)
            command = f"mv {Output_Dir}/predicted_*.fasta {Output_Dir}/{output_str}_gemoma.faa"
            subprocess.run(command, shell = True)

            #add file names to lists
            Gff_files.append(f"{Output_Dir}/{output_str}_gemoma.gff")
            Faa_files.append(f"{Output_Dir}/{output_str}_gemoma.faa")
    else:

        #run gemoma for each assembly in input
        for file in Input:

            #gets sample name
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #runs gemoma
            command = f"GeMoMa GeMoMaPipeline threads={Threads} t={file} g={GFF} "
            command += Params
            command += f" >{Log_Dir}/{output_str}_gemoma_stdout.txt 2> {Log_Dir}/{output_str}_gemoma_stderr.txt"
            subprocess.run(command, shell = True)

            #renames outputs to more meaningful names
            command = f"mv {Output_Dir}/final_*.gff {Output_Dir}/{output_str}_gemoma.gff"
            subprocess.run(command, shell = True)
            command = f"mv {Output_Dir}/predicted_*.fasta {Output_Dir}/{output_str}_gemoma.faa"
            subprocess.run(command, shell = True)

            #add file names to lists
            Gff_files.append(f"{Output_Dir}/{output_str}_gemoma.gff")
            Faa_files.append(f"{Output_Dir}/{output_str}_gemoma.faa")

    #gets metrics(has gemoma bool true for proper processing)
    gene_prediction_metrics(Metrics_Dir, Gff_files, Metric_Name, False, True)

    #returns lists of faa and gff
    return (Faa_files, Gff_files)


def rRNA_prediction(Input, Log_Dir, Output_Dir, Metrics_Dir, Default, Params, Threads, Metric_Name):
    """
    Runs rRNA prediction via barrnap

    Args:
        Input: list of strings containing file paths to assemblies
        Log_Dir: string of path to log directory
        Output_Dir: string of path to prediction output directory
        Metrics_Dir: string of path to metric directory
        Default: boolean indicating whether to use default barrnap parameters
        Params: string of barrnap parameters
        Threads: number of cpu threads
        Metric_Name: string containing the name of the prediction metric summary file         

    Returns:
        Nothing (as barrnap results do not need to be passed to annotation tools)
    """

    #list to hold gff files
    Gff_files = []


    #If default run barrnap with default params else use user input params
    if (Default):

        #run barrnap for each assembly in input
        for file in Input:

            #gets sample name
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #runs barrnap
            command = f"barrnap --threads {Threads} {file} 2> {Log_Dir}/{output_str}_barrnap_log.txt | grep 'Name=16S_rRNA;product=16S ribosomal RNA' > {Output_Dir}/{output_str}_barrnap.gff"
            subprocess.run(command, shell = True)

            #add file name to list
            Gff_files.append(f"{Output_Dir}/{output_str}_barrnap.gff")
    else:

        #run barrnap for each assembly in input
        for file in Input:

            #gets sample name
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #runs barrnap
            command = f"barrnap --threads {Threads} {file} "
            command += Params
            command += f" 2> {Log_Dir}/{output_str}_barrnap_log.txt | grep 'Name=16S_rRNA;product=16S ribosomal RNA' > {Output_Dir}/{output_str}_barrnap.gff"
            subprocess.run(command, shell = True)

            #add file name to list
            Gff_files.append(f"{Output_Dir}/{output_str}_barrnap.gff")

    #gets metrics(rRNA bool true for accurate metrics + rRNA prediction metrics are saved differently from CDS prediction metrics)
    gene_prediction_metrics(Metrics_Dir, Gff_files, Metric_Name, True)


def gene_prediction_metrics(Metrics_Dir, Gff_files, Metric_Name, rRNA_bool=False, gemoma_bool=False):
    """
    Gets gene prediction metrics(CDS counts + CDS length or 16S counts + 16S length) 

    Args:
        Metrics_Dir: string of path to metric directory
        Gff_files: list of strings containing gff file paths
        Metric_Name: string containing the name of the prediction metric summary file
        rRNA_bool: boolean indicating whether to get rRNA metrics
        gemoma_bool: boolean indicating whether gemoma was used to produce gff files

    Returns:
        Nothing (writes tsv files)
    """

    #lists to hold lengths and counts
    cds_lengths = []
    cds_counts = []

    #for each gff file get metrics
    for file in Gff_files:

        #if gemoma, count command varies from prodigal so account for that
        if (not gemoma_bool):
            count_command = f"grep -v '#' {file} | wc -l"
        else:
            count_command = f"grep -v '#' {file} | awk '$3 == \"CDS\" {{print $3}}' | wc -l"

        #get counts
        count_str = subprocess.run(count_command, shell = True, text = True, capture_output = True).stdout
        count_str = count_str.split()[0]
        cds_counts.append(int(count_str))

        #if gemoma, length command varies from prodigal so account for that
        if (not gemoma_bool):
            length_command = f"grep -v '#' {file} | awk '{{sum += ($5 - $4); }} END {{print sum/NR;}}'"
        else:
            length_command = f"grep -v '#' {file} | awk '$3 == \"CDS\" {{print $0}}' | awk '{{sum += ($5 - $4); }} END {{print sum/NR;}}'"

        #get lengths
        length_str = subprocess.run(length_command, shell = True, text = True, capture_output = True).stdout
        length = round(float(length_str))
        cds_lengths.append(length)

    #create list for writing outputs
    out_list = []

    #header is different if rRNA or not rRNA
    if (not rRNA_bool):
        out_list.append("File\tCDS_Count\tMean_CDS_length\n")
    else:
        out_list.append("File\t16S_Count\tMean_16S_length\n")

    #format the data for writing out
    for length,count,file in zip(cds_lengths, cds_counts, Gff_files):
        name = subprocess.run(f"basename {file} .gff", shell = True, text=True, capture_output = True).stdout
        name = name.strip()
        out_list.append(f"{name}\t{count}\t{length}\n")

    #joins the list to create the output string
    out_contents = "".join(out_list)

    #file name is different if rRNA
    if (rRNA_bool):
        output_file = open(f"{Metrics_Dir}/{Metric_Name}_rRNA.tsv", 'w')
    else:
        output_file = open(f"{Metrics_Dir}/{Metric_Name}.tsv", 'w')

    #write contents
    output_file.write(out_contents)

    #closes output file
    output_file.close()

def clean_faa(faa_files):
    """
    Cleans fasta files for annotation(removes *)

    Args:
        faa_files: list containing faa file paths for cleaning

    Returns:
        Nothing (overwrites FAA files)
    """

    #for file in faa_files, clean them by removing asteriks
    for file in faa_files:
        command = f"sed -i 's/\*//g' {file}"
        subprocess.run(command, shell = True)

def InterPro_annotation(Input, Interpro_Path, Default, Params, Log_Dir, Output_Dir, Metric_Dir, Threads, Metric_Name):
    """
    Runs gene annnotation via InterPro

    Args:
        Input: list of strings containing file paths to cleaned faa files
        Log_Dir: string of path to log directory
        Output_Dir: string of path to annotation output directory
        Metrics_Dir: string of path to metric directory
        Default: boolean indicating whether to use default InterPro parameters
        Params: string of InterPro parameters
        Metric_Name: string containing the name of the annotation metric summary file         

    Returns:
        Nothing (all output files are written to approriate directories)
    """

    #list to hold annotated gff file names
    Annotated_Gff_files = []

    #if default, run Interpro with default parameters
    if (Default):

        #run inteepro for each faa input 
        for file in Input:

            #get output name prefix
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #run Interpro
            command = f"./{Interpro_Path} -i {file} -f gff3 -o {Output_Dir}/{output_str}_interpro.gff -appl Pfam,SMART,TIGRFAM,ProSitePatterns,CDD,PRINTS,SUPERFAMILY --goterms --pathways -cpu {Threads} > {Log_Dir}/{output_str}_intepro_stdout.txt 2> {Log_Dir}/{output_str}_intepro_stderr.txt"
            subprocess.run(command, shell = True)

            #add file names to list
            Annotated_Gff_files.append(f"{Output_Dir}/{output_str}_interpro.gff")
    else:

        #run interpro for each faa input 
        for file in Input:

            #get output name prefix
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #run Interpro
            command = f"./{Interpro_Path} -i {file} -f gff3 -o {Output_Dir}/{output_str}_interpro.gff "
            command += Params
            command += f" -cpu {Threads} > {Log_Dir}/{output_str}_intepro_stdout.txt 2> {Log_Dir}/{output_str}_intepro_stderr.txt"
            subprocess.run(command, shell = True)

            #add file names to list
            Annotated_Gff_files.append(f"{Output_Dir}/{output_str}_interpro.gff")

    #get annotation metrics
    annotation_metrics(Metric_Dir, Annotated_Gff_files, Metric_Name)

def Eggnog_annotation(Input_faa, Input_gff, Eggnog_DB, Default, Params, Log_Dir, Output_Dir, Metric_Dir, Threads, Metric_Name):
    """
    Runs gene annnotation via InterPro

    Args:
        Input: list of strings containing file paths to cleaned faa files
        Log_Dir: string of path to log directory
        Output_Dir: string of path to annotation output directory
        Metrics_Dir: string of path to metric directory
        Default: boolean indicating whether to use default Eggnog parameters
        Params: string of Eggnog parameters
        Metric_Name: string containing the name of the annotation metric summary file         

    Returns:
        Nothing (all output files are written to approriate directories)
    """

    #list to hold annotated gff file names
    Annotated_Gff_files = []

    #if default, run Eggnog with default parameters
    if (Default):

        #run eggnog for each faa input 
        for faa_file, gff_file in zip(Input_faa, Input_gff):

            #get output prefix
            name = subprocess.run(f"basename {faa_file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #run eggnog
            command = f"emapper.py -i {faa_file} --decorate_gff {gff_file} --output_dir {Output_Dir} --output {output_str}_eggnog --data_dir={Eggnog_DB} --cpu {Threads} --tax_scope bacteria --go_evidence all --override > {Log_Dir}/{output_str}_eggnog_stdout.txt 2> {Log_Dir}/{output_str}_eggnog_stderr.txt"
            subprocess.run(command, shell = True)

            #get output annotated gff file name and add to list
            command = f"ls {Output_Dir}/{output_str}_eggnog*.gff"
            Annotated_Gff = subprocess.run(command, shell=True, text=True, capture_output=True).stdout
            Annotated_Gff_files.append(Annotated_Gff.strip())
    else:

        #run eggnog for each faa input 
        for faa_file, gff_file in zip(Input_faa, Input_gff):

            #get output prefix
            name = subprocess.run(f"basename {file}", shell = True, text=True, capture_output = True).stdout
            name = name.split(".")
            name.pop()
            output_str = "".join(name)

            #run eggnog
            command = f"emapper.py -i {faa_file} --decorate_gff {gff_file} --output_dir {Output_Dir} --output {output_str}_eggnog --data_dir={Eggnog_DB} --cpu {Threads} "
            command += Params
            command += f" --override > {Log_Dir}/{output_str}_eggnog_stdout.txt 2> {Log_Dir}/{output_str}_eggnog_stderr.txt"
            subprocess.run(command, shell = True)

            #get output annotated gff file name and add to list
            command = f"ls {Output_Dir}/{output_str}*.gff"
            Annotated_Gff = subprocess.run(command, shell=True, text=True, capture_output=True).stdout
            Annotated_Gff_files.append(Annotated_Gff.strip())
                                       
    #get annotation metrics(eggnog bool set to True for proper output)
    annotation_metrics(Metric_Dir, Annotated_Gff_files, Metric_Name, True)

def annotation_metrics(Metrics_Dir, Annotated_Gff_files, Metric_Name, eggnog_bool=False):
    """
    Runs gene annnotation via InterPro

    Args:
        Metrics_Dir: string of path to metric directory
        Annotated_Gff_files: list of strings containig annotated gff file paths
        eggnog_bool: indicates whether eggnog was used for gene annotation

    Returns:
        Nothing (all output files are written to approriate directories)
    """

    #list to hold annotation counts
    annotation_counts = []

    #gets metrics for each annotated gff file
    for file in Annotated_Gff_files:
        
        #get prediction method name from file path
        name = file.split("_")[-2]

        #gemoma is handled different than prodigal so account for that
        #also account for command based on eggnog bool
        if (name == "gemoma" and eggnog_bool):
            add_str = "| awk '$3 == \"mRNA\" {{print $0}}' "
        elif (name == "gemoma"):
            add_str = "| grep -v \'>\'"
        else:
            add_str = ""
        if (eggnog_bool):
            count_command = f"grep -v \'#\' {file} {add_str}| cut -f9 | sort | uniq | wc -l"
        else:
            count_command = f"grep -v \'#\' {file} {add_str}| cut -f1 | sort | uniq | wc -l"

        #get counts of annotations
        count_str = subprocess.run(count_command, shell = True, text = True, capture_output = True).stdout
        annotation_counts.append(int(count_str))
        
    #output list
    out_list = []

    #header
    out_list.append("File\tAnnotation_Count\n")

    #sets output data
    for count,file in zip(annotation_counts, Annotated_Gff_files):
        name = subprocess.run(f"basename {file} .gff", shell = True, text=True, capture_output = True).stdout
        name = name.strip()
        out_list.append(f"{name}\t{count}\n")

    #joins the list to create the output string
    out_contents = "".join(out_list)

    #opens and writes to the output file
    output_file = open(f"{Metrics_Dir}/{Metric_Name}.tsv", 'w')
    output_file.write(out_contents)

    #closes output file
    output_file.close()

def error_checking(args):
    """
    Checks for common errors in inputs and outputs appropriate error messages

    Args:
        args: argparse arguments

    Returns:
        Nothing (stops program if error is found)
    """
    #prediction checks
    if (args.Prodigal and args.Gemoma):
        print("Error: -p and -g set: Cannot do both prodigal and gemoma prediction")
        sys.exit()
    if (not args.Prodigal and not args.Gemoma):
        print("Error: -p or -g not set: No specified CDS prediction method")
        sys.exit()

    #input assembly checks
    if (args.Input[0][-3:] == ".gz" and not args.Compressed):
        print("Error: -c not specified yet input appears to be compressed(.gz)")
        sys.exit()
    if (args.Input[0][-3:] != ".gz" and args.Compressed):
        print("Error: -c specified yet input appears to be uncompressed")
        sys.exit()

    #metric name checks
    if ("/" in args.Metric_Name):
        print("Error: / in prediction metric string: path likely specified instead of just file name")
        sys.exit()
    if ("/" in args.Ann_Metric_Name):
        print("Error: / in prediction metric string: path likely specified instead of just file name")
        sys.exit()

    #more prediction checks
    if (not args.Pred_Default and args.Prodigal and args.Prodigal_Parameters == None):
        print("Error: -pd not set with -p yet no prodigal parameters were set(no -pp or blank string after -pp)")
        sys.exit()
    if (not args.Pred_Default and args.Gemoma and args.Gemoma_parameters == None):
        print("Error: -pd not set with -g yet no gemoma parameters were set(no -gp or blank string after -gp)")
        sys.exit()
    if (not args.Pred_Default and args.RNA and args.rRNA_Parameters == None):
        print("Error: -pd not set with -g yet no gemoma parameters were set(no -gp or blank string after -gp")
        sys.exit()
    if (args.Gemoma and (args.Gemoma_Ref == None or args.Gemoma_Ann == None)):
        print("Error: -g specified yet no gemoma ref or gemoma annotation was given(no -gr or -ga or blank strings following those params)")
        sys.exit()

    #annotation checks
    if (not args.Only_Prediction):
        if (args.Eggnog and args.InterPro):
            print("Error: -eg and -ip set: Cannot do both eggnog and interpro annotation")
            sys.exit()
        if (not args.Eggnog and not args.InterPro):
            print("Error: -op not specified: must do one annotation method(-eg for eggnog -ip for interpro)")
            sys.exit()
        if (args.InterPro and args.InterPro_Script == None):
            print("Error: -ip specfied yet no interpro script specified(-isp) or string after -isp is blank")
            sys.exit()
        if (args.Eggnog and args.Eggnog_DB == None):
            print("Error: -eg specified yet no eggnog DB path specified(-ed) or string after -ed is blank")
            sys.exit()
        if (not args.Ann_Default and args.InterPro and args.InterPro_Parameters == None):
            print("Error: -ad not set with -ip yet no interpro parameters were set(no -ipp or blank string after -ipp)")
            sys.exit()
        if (not args.Ann_Default and args.Eggnog and args.Eggnog_Parameters == None):
            print("Error: -ad not set with -eg yet no eggnog parameters were set(no -ep or blank string after -ep)")
            sys.exit()
        
def default_dirs(args):
    """
    Creates default directories for outputs if none specified

    Args:
        args: argparse arguments

    Returns:
        updated argparse arguments based on directories set 
    """
    #Prediction Directories

    #logs
    if (args.Pred_Logs == None):
        pred_log_exists = subprocess.run("ls -d prediction_logs", shell = True, text=True, capture_output=True).stdout
        if (not pred_log_exists):
            subprocess.run("mkdir prediction_logs", shell = True)
        args.Pred_Logs = "./prediction_logs"

    #Output
    if (args.Pred_Output == None):
        pred_output_exists = subprocess.run("ls -d prediction_outputs", shell = True, text=True, capture_output=True).stdout
        if (not pred_output_exists):
            subprocess.run("mkdir prediction_outputs", shell = True)
        args.Pred_Output = "./prediction_outputs"

    #Metrics
    if (args.Pred_Metrics == None):
        pred_metric_exists = subprocess.run("ls -d prediction_metrics", shell = True, text=True, capture_output=True).stdout
        if (not pred_metric_exists):
            subprocess.run("mkdir prediction_metrics", shell = True)
        args.Pred_Metrics = "./prediction_metrics"



    #Annotation Directories


    if (not args.Only_Prediction):

        #Logs
        if (args.Ann_Logs == None):
            ann_log_exists = subprocess.run("ls -d annotation_logs", shell = True, text=True, capture_output=True).stdout
            if (not ann_log_exists):
                subprocess.run("mkdir annotation_logs", shell = True)
            args.Ann_Logs = "./annotation_logs"

        #Output
        if (args.Ann_Output == None):
            ann_output_exists = subprocess.run("ls -d annotation_outputs", shell = True, text=True, capture_output=True).stdout
            if (not ann_output_exists):
                subprocess.run("mkdir annotation_outputs", shell = True)
            args.Ann_Output = "./annotation_outputs"

        #Metrics
        if (args.Ann_Metrics == None):
            ann_metric_exists = subprocess.run("ls -d annotation_metrics", shell = True, text=True, capture_output=True).stdout
            if (not ann_metric_exists):
                subprocess.run("mkdir annotation_metrics", shell = True)
            args.Ann_Metrics = "./annotation_metrics"
    return(args)
            

def main():
    """
    Runs gene prediction and annotation pipeline using prodigal/gemoma(+ barrnap for rRNA gene prediction) for gene prediction and interpro/eggnog for annotation"

    Args:
        None(uses argparse args)

    Returns:
        Nothing (Writes outputs to appropriate directories)
    """

    #gets args, checks the args, and adjusts args(for default directories)
    pipeline = set_args()
    args = pipeline.parse_args()
    error_checking(args)
    args = default_dirs(args)


    #if input is compressed uncompressed input files and store in temp dir
    if (args.Compressed):
        temp_dir = tempfile.TemporaryDirectory()
        for file in args.Input:
            name = subprocess.run(f"basename {file} .gz", shell = True, text=True, capture_output = True).stdout
            command = f"gunzip -c {file} > {temp_dir.name}/{name}"
            subprocess.run(command, shell = True)

        #get temp file names for running gene prediction
        Input = subprocess.run(f"ls {temp_dir.name}", shell = True, text = True, capture_output = True).stdout
        Input = Input.strip().split()
        Input = [temp_dir.name + '/' + x for x in Input]


    #runs prodigal if prodigal flag is specified and changes input appropriate if input was specified as compressed or not
    if (args.Prodigal and not args.Compressed):
        Faa_files, Gff_files = prodigal_prediction(args.Input, args.Pred_Logs, args.Pred_Output, args.Pred_Metrics, args.Pred_Default, args.Prodigal_Parameters, args.Metric_Name)
    elif (args.Prodigal):
        Faa_files, Gff_files = prodigal_prediction(Input, args.Pred_Logs, args.Pred_Output, args.Pred_Metrics, args.Pred_Default, args.Prodigal_Parameters, args.Metric_Name)

    #runs prodigal if gemoma flag is specified and changes input appropriate if input was specified as compressed or not
    if (args.Gemoma and not args.Compressed):
        Faa_files, Gff_files = gemoma_prediction(args.Input, args.Pred_Logs, args.Pred_Output, args.Pred_Metrics, args.Pred_Default, 
                          args.Gemoma_parameters, args.Gemoma_ref, args.Gemoma_ann, args.Threads, args.Metric_Name)
    elif (args.Gemoma):
        Faa_files, Gff_files = gemoma_prediction(Input, args.Pred_Logs, args.Pred_Output, args.Pred_Metrics, args.Pred_Default, 
                          args.Gemoma_parameters, args.Gemoma_Ref, args.Gemoma_Ann, args.Threads, args.Metric_Name)


    #runs barrnap if RNA flag is specified and changes input appropriate if input was specified as compressed or not
    if (args.RNA and not args.Compressed):
        rRNA_prediction(args.Input, args.Pred_Logs, args.Pred_Output, args.Pred_Metrics, args.Pred_Default, args.rRNA_Parameters, args.Threads, args.Metric_Name)
    elif (args.RNA):
        rRNA_prediction(Input, args.Pred_Logs, args.Pred_Output, args.Pred_Metrics, args.Pred_Default, args.rRNA_Parameters, args.Threads, args.Metric_Name)

    #if input was compressed remove the directory containing the uncompressed files
    if (args.Compressed):
        subprocess.run(f"rm -r {temp_dir.name}", shell = True)

    #prints message indicating gene prediction has finished
    print(f"Gene Prediction Completed! Logs verifying completion can be found in {args.Pred_Logs}.")


    #if flag for only prediction quit here
    if (args.Only_Prediction):
        sys.exit()

    #clean faa files for annotation
    clean_faa(Faa_files)

    #runs gene annotation with Interpro if interpro flag specified
    if (args.InterPro):
        InterPro_annotation(Faa_files, args.InterPro_Script, args.Ann_Default, args.InterPro_Parameters, 
                            args.Ann_Logs, args.Ann_Output, args.Ann_Metrics, args.Threads, args.Ann_Metric_Name)
    #runs gene annotation with Eggnog if eggnog flag specified
    elif (args.Eggnog):
        Eggnog_annotation(Faa_files, Gff_files, args.Eggnog_DB, args.Ann_Default, args.Eggnog_Parameters, 
                          args.Ann_Logs, args.Ann_Output, args.Ann_Metrics, args.Threads, args.Ann_Metric_Name)

        #sometimes tmp emapper dir does not remove if some warning/error occurs during eggnog, so attempt to remove it
        #for next run
        tmp_dir_exists = subprocess.run("ls -d emappertmp_*", shell = True, text=True, capture_output=True).stdout
        if (tmp_dir_exists != ''):
            subprocess.run("rm -r emappertmp_*", shell=True)

    #prints message indicating gene annotation has finished
    print(f"Gene Annotation Completed! Logs verifying completion can be found in {args.Ann_Logs}.")

#Runs pipeline
main()
    