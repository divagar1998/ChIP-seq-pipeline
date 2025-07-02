#! /bin/bash

bam_file=$1
peak_file=$2

ml bedtools/2.29.0
ml samtools/1.17

echo $bam_file
read_count=$(samtools view -c "$bam_file")

bedtools bamtobed -i $bam_file | awk 'BEGIN{OFS="\t"}{$4="N";$5="1000";print $0}' > "${bam_file}.tagAlign"
reads_in_peaks=$(bedtools sort -i "$peak_file" | bedtools merge -i stdin | bedtools intersect -u -a "${bam_file}.tagAlign" -b stdin | wc -l)

echo "$(printf "%.2f" $(echo "$reads_in_peaks / $read_count" | bc -l))"
