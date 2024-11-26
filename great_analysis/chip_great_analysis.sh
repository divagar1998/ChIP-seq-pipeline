#! /bin/bash

ml bedtools/2.31.0

chip_peak_file=$1
intersect_file=$2
output_file=$3

bedtools intersect -a $chip_peak_file -b $intersect_file > temp.narrowPeak
sort -k8,8n temp.narrowPeak > temp2.narrowPeak
head -n 500 temp2.narrowPeak > $output_file


