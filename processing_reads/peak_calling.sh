#! /bin/bash

ml macs/2.1.0
ml bedgraphtobigwig/2018-01-30

input_csv=$1
chrom_size=$2

#col1 is directory of bam files, col2 is name for peak files, col3 is name of chip bam file, col4 is name of input bam file
while IFS=, read -r col1 col2 col3 col4; do
    cd $col1
    mkdir -p peak_calling
    macs2 callpeak \
        -t $col3 \
        -c $col4 \
        -g hs \
        -n $col2 \
        -f BAM \
        -B \
        --keep-dup 'all' \
        --outdir ./peak_calling

    sort -k1,1 -k2,2n "${col2}_treat_pileup.bdg" > temp1.bdg
    sort -k1,1 -k2,2n "${col2}_control_lambda.bdg" > temp2.bdg

    bedGraphToBigWig temp1.bdg $chrom_size "${col2}_chip.bw"
    bedGraphToBigWig temp2.bdg $chrom_size "${col2}_input.bw"

    rm temp1.bdg
    rm temp2.bdg

done < $input_csv
