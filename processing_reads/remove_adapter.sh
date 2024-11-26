#! /bin/bash
set -euo pipefail

input_csv=$1

ml cutadapt
ml fastqc

while IFS=, read -r col1 col2;
do
    IFS=. read -r -a fastq_file <<< ${col1}
    cutadapt -a ${col2} -o "${fastq_file}_cutadapt.fastq.gz" "${fastq_file}.fastq.gz" --minimum-length 35 -q 30
    fastqc -t 32 "${fastq_file}_cutadapt.fastq.gz"
done < ${input_csv}

