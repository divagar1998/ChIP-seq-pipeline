#! /bin/bash

# run script in cnvkit_emv with conda

# Note:This script is written to run on input sequenced reads, which serve as
# a proxy for low depth WGS

input_csv=$1
# ref genome in fasta
ref_genome=$2
# in bed format
gene_annotation=$3

# col1 contains target input bam file
# col2 contains reference from CCLE
while IFS=, read -r col1; do
    # cnvkit.py batch $col1 -p 10 -n -m wgs -f $ref_genome --annotate $gene_annotation -d results/
    cnvkit.py batch $col1 -p 10 -m wgs -r reference.cnn -d results/
done < $input_csv
