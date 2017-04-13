# Installation and usage documentation of metagenomics-database (2017)
![](https://img.shields.io/badge/last%20edited-12--04--2017-yellow.svg)
![](https://img.shields.io/badge/author-Leandro%20Corrêa-blue.svg)


# CONTENTS OF THIS FILE
* [Introduction](#introduction)
* [Software requirements](#software-requirements)
* [Data dictionary](#data-dictionary)
* [Metadata](#metadata)
* [Scripts](#scripts)


# Introduction
This document is about the metagenomic database project. The goal is to create a metagenomic sample management system that helps to identify relationships and features based on some information that will be obtained from metagenomic samples.

# Software Requirements
Docker platform with mongodb is required. To install the mongodb image in docker follow the instructions:

## Create mongo database
* docker run --name mongoDB-Metagenomics -v /docker/mongoDB-Metagenomics/datadir:/data/db -p 7755:27017 -d mongo --auth
* docker start mongoDB-Metagenomics
* docker exec -it mongoDB-Metagenomics mongo admin
* db.sequences.ensureIndex({id_seq: 1})

# Data Dictionary
The database supports five different types of analysis. Below the table that contains the name of the key identifier in the database, and the type of tool used in the analysis.

* First column is the indexes; 
* Second collum is the names identified in the metagenomic-database; 
* Third column refers to the 'type of analysis';
* Fourth the example of data.

Index | Name Identifier | Analysis | Example
------------ | ------------- | ------------ | -------------
0 | id_sample | Metadata | sample_01
1 | id_seq | Metadata | contig72585_1_431_+
2 | project | Metadata | project_amazon
3 | sequence | Interpro | contig	
4 | start_location | Interpro | 12
5 | stop_location | Interpro | 125
6 | signature_accession | Interpro | PF09103
7 | signature_description | Interpro | BRCA2 repeat profile
8 | protein_analysis | Interpro | Pfam
9 | score | Interpro | 2.3E-18
10 | interpro_accession | Interprol | IPR002093
11 | interpro_description | Interpro | BRCA2 repeat
12 | protem_seq | Interpro | 
13 | go_annotations | Interpro | GO:0005515
14 | kegg_Pathways | Interpro | binario
15 | reactome_pathways | Interpro | R-HSA-111457 
16 | metacyc_pathways | Interpro | 00230+2.7.7.7
17 | kegg_ko | KAAS | K06160
18 | id_taxon | Kaiju | 1348852
19 | kingdom | Kaiju | Bacteria
20 | phylum | Kaiju | Actinobacteria
21 | class | Kaiju | Actinobacteria
22 | order | Kaiju | Propionibacteriales
23 | family | Kaiju | Nocardioidaceae
24 | genre | Kaiju | Mumia
25 | species | Kaiju | Mumia flava
26 | blast_id | Blast |gb[CP014028.1]
27 | blast_hit | Blast | Achromobacter xylosoxidans strain FDAARGOS_150, c...
28 | blast_score | Blast | 100
29 | blast_evalue | Blast | 8e-18
30 | proteomics | Proteomic analysis | True


# Metadata
All scripts must be accompanied by their corresponding metadata that will inform: name of the sample, name of the project, the type of the input sequence, date, and so on. The metadata must be accompanied by the sample, or designated from the -m parameter.

The metadata must be contained in a .csv table with the headers: index (containing the parameter name) and Requirement (containing the parameter value). As in the example below:

Index | Identifier 
------------ | ------------- 
sample_name | sample_01 
type_sequence | contig
project | project_amazon 
data | 04.12.2017
latitude | 1°25'53.4"S 
longitude | 48°29'32.0"W

# Scripts
There are five scripts for inputting the data into the database: interpro_mongo.py, kaas_mongo.py, blast_mongo.py, kaiju_mongo.py and proteomic-hit_mongo.py. Each one is responsible for entering information from each one of the five analyzes developed.

The steps generation of inputs and execution of scripts are shown below.

### 1- Interpro
The first analysis involves the execution of the [interproscan](https://github.com/ebi-pf-team/interproscan/wiki/InterProScan5OutputFormats) tool. 

Run the interproscan tool considering an output format of type .tsv.
```
$ interproscan.sh -dp --appl PfamA,TIGRFAM,PRINTS,PrositePatterns,Gene3d --goterms --pathways -f tsv -o interpro_output.tsv -i input.fasta
```
The results are entered into the database from the script interpro_mongo.py
```
$ python interpro_mongo.py -i interpro_output.tsv
```

### 2- Kaas
[KAAS](http://www.genome.jp/tools/kaas) is an online tool that uses the KEGG database to identify orthologous groups homologous to sequences.

Submit the sequences and download the results of the identified ortholog groups. The results are entered into the database from the script kaas_mongo.py
```
$ python kaas_mongo.py -i kaas_output.kaas
```

### 3- Blast
[BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) also works with sequence homology analysis.

Run the blast tool and put the results are entered into the database from the script blast_mongo.py
```
$ python blast_mongo.py -i blast_output.out
```
### 4- Kaiju
[Kaiju](https://github.com/bioinformatics-centre/kaiju) is a program for the taxonomic classification of high-throughput sequencing reads. 

After installation, run the kaiju tool with the following parameters:
```
$ kaiju -z 4 -t ~/nodes.dmp -f ~/blast_nr/kaiju_db_nr.fmi -a greedy -e 5 -m 12 -s 70 -i input.fasta -o kaiju_output.out
```
The results will be entered into the bank from the script:
```
$ python kaiju_mongo.py -i kaiju_output.out
```
### 5- Proteomic hit
Proteomic analysis identifies protein sequences from a reference genome/metagenome. To enter the analysis results in the database you must execute the script proteomic-hit_mongo.py passing as reference the file fasta generated in the analysis.
```
$ python kaiju_mongo.py -i proteomic-hit.fasta
```

## Data download URL
* Link to obtain the input data that can be used as an example
    * https://www.dropbox.com/home/metagenomics-database
