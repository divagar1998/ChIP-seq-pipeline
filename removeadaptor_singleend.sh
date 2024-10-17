#! /bin/bash
set -euo pipefail

fastq_file=$1
adaptor_seq=$2
cell_line=$3

# file path of fastq file
PATH="/hpc/users/divagt01/watanabe/Divagar/cmyc_chipseq_analysis/cmyc_cell_lines/${cell_line}"

ml cutadapt

cutadapt -a ${adaptor_seq} -o ./"${cell_line}/${fastq_file}_cutadapt.fastq.gz" ./"${cell_line}/${fastq_file}.fastq.gz" -m 50

ml fastqc

# quality control of fastq file
fastqc -t 4 ./"${cell_line}"/"${fastq_file}_cutadapt.fastq.gz"
echo "fastq file quality checked"
