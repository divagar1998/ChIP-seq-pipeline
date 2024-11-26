#! /bin/bash
# for single end sequencing

set -euo pipefail

ml sratoolkit
ml fastqc

input_csv=$1
file_path=$2
cd "${file_path}"

while IFS="," read -r cell_line SRR;
do
        mkdir -p "${cell_line}"
        cd ./"${cell_line}"
        IFS="," read -r -a sra_numbers <<< ${SRR}

        for sra in "${sra_numbers[@]}";
        do
                echo "${sra}"
                fasterq-dump --threads 32 --progress ${sra}
                gzip ./"${sra}.fastq"
                fastqc -t 32 ./"${sra}.fastq.gz"
        done
        cd "${file_path}"
done < ${input_csv}
