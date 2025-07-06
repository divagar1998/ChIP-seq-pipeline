#! /bin/bash

ml macs/2.1.0

input_csv=$1
#1-cell line dir, #2-name for peak file, #3 treat bam, #4 input bam
while IFS=, read -r col1 col2 col3 col4; do
    cd $col1
    mkdir -p peak_calling
    macs2 callpeak \
        -t  $col3 \
        -c  $col4 \
        -g 2913022398 \
        -n $col2 \
        -f BAMPE \
        -B \
        --keep-dup 'all' 
    mv *"${col2}"* peak_calling
done < $input_csv