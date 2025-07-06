#! /bin/bash

ml bedtools/2.29.0
ml python/3.12.5

chip1=$1
chip2=$2
chip3=$3

cat $chip1 $chip2 $chip3 > SCLC_N_all_cmyc_peaks.narrowPeak
sort -k1,1 -k2,2n SCLC_N_all_cmyc_peaks.narrowPeak > SCLC_N_all_cmyc_peaks.sorted.narrowPeak
bedtools merge -i SCLC_N_all_cmyc_peaks.sorted.narrowPeak -d 25 > SCLC_N_all_cmyc_peaks.sorted.merged.narrowPeak

bedtools intersect -wa -a SCLC_N_all_cmyc_peaks.sorted.merged.narrowPeak -b $chip1 > H2171_merged_peaks.bed
bedtools intersect -wa -a SCLC_N_all_cmyc_peaks.sorted.merged.narrowPeak -b $chip2 > H82_merged_peaks.bed
bedtools intersect -wa -a SCLC_N_all_cmyc_peaks.sorted.merged.narrowPeak -b $chip3 > H524_merged_peaks.bed

bedtools intersect -wa -a H2171_merged_peaks.bed -b H82_merged_peaks.bed > intersect_H2171_H82.bed
bedtools intersect -wa -a H2171_merged_peaks.bed -b H524_merged_peaks.bed > intersect_H2171_H524.bed
bedtools intersect -wa -a H82_merged_peaks.bed -b H524_merged_peaks.bed > intersect_82_H524.bed
bedtools intersect -wa -a intersect_H2171_H82.bed -b H524_merged_peaks.bed > intersect_2171_82_H524.bed

python3 plot_chip_intersect_venn.py H2171_merged_peaks.bed H82_merged_peaks.bed H524_merged_peaks.bed \
    intersect_H2171_H82.bed intersect_H2171_H524.bed intersect_82_H524.bed intersect_2171_82_H524.bed


