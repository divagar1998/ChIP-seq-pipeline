#! /bin/bash
# for paired end sequencing
# does not have adaptor removal step

set -euo pipefail

ml sratoolkit
ml fastqc
ml proxies

input_csv=$1

# col1 is directory for cell line, col2 is cell line, col3 is SRA for chip, col4 is SRA for input
while IFS=, read -r col1 col2 col3 col4; do
        mkdir -p $col1
        cd $col1
        fasterq-dump --threads 10 --progress $col3 -O .
        fasterq-dump --threads 10 --progress $col4 -O .
        
        #gunzip the fastq file
        gzip --verbose ./"${col3}_R1.fastq"
        gzip --verbose ./"${col3}_R2.fastq"
	gzip --verbose ./"${col4}_R1.fastq"
        gzip --verbose ./"${col4}_R2.fastq"

        # quality control of fastq file
        fastqc -t 10 ./"${col3}_R1.fastq.gz"
        fastqc -t 10 ./"${col3}_R2.fastq.gz"
	fastqc -t 10 ./"${col4}_R1.fastq.gz"
        fastqc -t 10 ./"${col4}_R2.fastq.gz"

done < $input_csv

