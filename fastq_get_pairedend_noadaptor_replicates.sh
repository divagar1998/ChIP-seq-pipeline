#! /bin/bash
# for paired end sequencing
# does not have adaptor removal step

set -euo pipefail

#cell line
cell_line=$1

ml sratoolkit
ml fastqc
#vdb-config -i

# the SRA number of the ChIP data
SRA_rep1=$2
SRA_rep2=$3

# the SRA number of the input data
SRA_input_rep1=$4
SRA_input_rep2=$5

SRA_files=([1]=$SRA_rep1 [2]=$SRA_rep2 [3]=$SRA_input_rep1 [4]=$SRA_input_rep2)

# extract the fastq file
for i in "${SRA_files[@]}"
do
        if [ -e ./"${cell_line}"/"${i}_1".fastq ] && [ -e ./"${cell_line}"/"${i}_2".fastq ]
        then echo "fastq file exists"
        else fasterq-dump --threads 32 --progress "${i}" -O ./"${cell_line}"/
        echo "fastq file downloaded"
        fi
done


#gunzip the fastq file
for i in "${SRA_files[@]}"
do
        if [ -e ./"${cell_line}"/"${i}_1".fastq.gz ] && [ -e ./"${cell_line}"/"${i}_2".fastq.gz ]
        then echo "fastq file gzipped"
        else
                gzip --verbose ./"${cell_line}"/"${i}_1".fastq
                gzip --verbose ./"${cell_line}"/"${i}_2".fastq
                echo "fastq file gunzipped"
        fi
done

# quality control of fastq file
for i in "${SRA_files[@]}"
do
        fastqc -t 32 ./"${cell_line}"/"${i}_1".fastq.gz
        fastqc -t 32 ./"${cell_line}"/"${i}_2".fastq.gz
done
echo "fastq file quality checked"
