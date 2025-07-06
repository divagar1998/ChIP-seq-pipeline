#! /bin/bash
# for paired end sequencing

set -euo pipefail

ml sratoolkit/3.1.1
ml fastqc/0.11.9
ml proxies

input_csv=$1

# col1 is directory for output files, col2 is output file name, col3 is SRA
while IFS=, read -r col1 col2 col3; do
        mkdir -p $col1
        cd $col1
        fasterq-dump --threads 10 --progress $col3 -O .
        mv "${col3}_1.fastq" "${col2}_R1.fastq"
        mv "${col3}_2.fastq" "${col2}_R2.fastq"
        
        #gunzip the fastq file
        gzip --verbose ./"${col2}_R1.fastq"
        gzip --verbose ./"${col2}_R2.fastq"

        # quality control of fastq file
        fastqc -t 10 ./"${col2}_R1.fastq.gz"
        fastqc -t 10 ./"${col2}_R2.fastq.gz"


done < $input_csv

