#! /bin/bash
set -euo pipefail

fastq_file_mate1=$1
fastq_file_mate2=$2
adaptor_seq_fwd=$3
adaptor_seq_rev=$4
cell_line=$5

cd "/hpc/users/divagt01/watanabe/Divagar/cmyc_chipseq_analysis/cmyc_cell_lines/${cell_line}"

ml cutadapt

cutadapt -a ${adaptor_seq_fwd} -A ${adaptor_seq_rev} -o ./"${fastq_file_mate1}_cutadapt.fastq.gz" -p ./"${fastq_file_mate2}_cutadapt.fastq.gz" ./"${fastq_file_mate1}.fastq.gz" ./"${fastq_file_mate2}.fastq.gz" --minimum-length=50

ml fastqc

# quality control of fastq file
fastqc -t 4 ./"${fastq_file_mate1}_cutadapt.fastq.gz"
fastqc -t 4 ./"${fastq_file_mate2}_cutadapt.fastq.gz"
echo "fastq file quality checked"
