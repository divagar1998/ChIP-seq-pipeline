#! /bin/bash
# for unpaired/single end sequencing
# does not have adaptor removal step

set -euo pipefail

#cell line
cell_line=$1

ml sratoolkit
ml fastqc
#vdb-config -i

# the SRA number of the ChIP data
SRA=$2

# the SRA number of the input data
SRA_input=$3

# check if SRA data has already been downloaded
if [ -e ./"${cell_line}"/"${SRA}".fastq.gz ]
then
        echo "SRA file exists"
else
        echo "SRA file does not exist"

        # extract the fastq file
        fasterq-dump --threads 32 --progress $SRA -O ./"${cell_line}"/
        echo "fastq file downloaded"

        #gunzip the fastq file
        gzip --verbose ./"${cell_line}"/"${SRA}".fastq
        echo "fastq file gunzipped"

        # quality control of fastq file
        fastqc -t 32 ./"${cell_line}"/"${SRA}".fastq.gz
        echo "fastq file quality checked"
fi

# check if SRA input data has already been downloaded
if [ -e ./"${cell_line}"/"${SRA_input}".fastq.gz ]
then
        echo "SRA file for input exists"
else
        echo "SRA file for input does not exist"

        # extract the fastq file
        fasterq-dump --threads 32 --progress $SRA_input -O ./"${cell_line}"/
        echo "fastq file downloaded"

        #gunzip the fastq file
        gzip --verbose ./"${cell_line}"/"${SRA_input}".fastq
        echo "fastq file gunzipped"

        # quality control of fastq file
        fastqc -t 32 ./"${cell_line}"/"${SRA_input}".fastq.gz
        echo "fastq file quality checked"
fi

