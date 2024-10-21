#! /bin/bash
set -euo pipefail

fastq_filepath=$1
output_directory=$2

ml fastqc

fastqc -t 32 ${fastq_filepath} -o ${output_directory}
