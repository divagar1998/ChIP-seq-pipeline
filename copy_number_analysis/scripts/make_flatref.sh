#! /bin/bash

input_genome_access_file=$1
output_split_genome_path=$2
genome_fasta_path=$3
annotation_file=$4

#python3 split_bed.py $input_genome_access_file $output_split_genome_path

cnvkit.py target $input_genome_access_file --annotate $annotation_file --split --avg-size 100000 -o $output_split_genome_path

cnvkit.py reference -o ./output/FlatReference.cnn -f $genome_fasta_path -t $output_split_genome_path
