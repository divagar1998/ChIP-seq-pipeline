#! /bin/bash
set -euo pipefail

input_csv=$1

ml cutadapt/4.2
ml fastqc/0.11.9

while IFS=, read -r col1 col2;
do
    fastq_file="${col1%_R1*}"
    # Change minimum length of reads to be retained accordingly
    cutadapt -a ${col2} -A ${col2}  --minimum-length 35 -q 30 -j 10 \
    -o "${fastq_file}_R1_cutadapt.fastq.gz" -p "${fastq_file}_R2_cutadapt.fastq.gz" \
    "${fastq_file}_R1.fastq.gz" "${fastq_file}_R2.fastq.gz"

    fastqc -t 10 "${fastq_file}_R1_cutadapt.fastq.gz"
    fastqc -t 10 "${fastq_file}_R2_cutadapt.fastq.gz"
done < ${input_csv}
