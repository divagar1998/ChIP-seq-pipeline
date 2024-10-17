#! /bin/bash

set -euo pipefail

cell_line=$1

#bam_file_path= ./${cell_line}/${cell_line}_cmyc_chip_woblacklist.sorted.rmdup.bam
#narrowPeak_file_path= ./${cell_line}/peak_calling/${cell_line}_peaks_peaks.narrowPeak

ml bedtools
ml samtools

samtools view -c -@ 32 "./${cell_line}/${cell_line}_cmyc_chip_woblacklist_rep1.sorted.rmdup.bam"
wc -l "./${cell_line}/peak_calling_new_fdr/${cell_line}_peaks_peaks.narrowPeak"
bedtools sort -i "./${cell_line}/peak_calling_new_fdr/${cell_line}_peaks_peaks.narrowPeak" | bedtools merge -i stdin | bedtools intersect -u -a "./${cell_line}/${cell_line}_cmyc_chip_woblacklist_rep1.sorted.rmdup.bam" -b stdin -ubam | samtools view -c -@ 32
