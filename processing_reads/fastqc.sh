#! /bin/bash
set -euo pipefail

input_file=$1

ml fastqc

# col1 contains the directory paths with fastq files
while IFS=, read -r col1;
do
    cd $col1
    # -L for symbolic links
    fastq_files=($(find -L -type f -name "*fastq.gz"))
    
    for file in "${fastq_files[@]}"; do
        fastqc -t 32 ${file}
    done
done < ${input_file}
