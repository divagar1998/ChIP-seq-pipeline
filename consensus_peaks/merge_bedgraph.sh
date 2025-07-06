#!/bin/bash

# Input files
#sort -k1,1 -k2,2n input.bed > sorted.bed

SHARED_BED="SCLC_N_H3K27ac_shared_peaks.bed"
BDG1="~/watanabe/Divagar/ChIP_seq_files/H2171_k27ac/peak_calling/H2171_k27ac_peaks_treat_pileup_normalized.bdg"
BDG2="~/watanabe/Divagar/ChIP_seq_files/H82_k27ac/peak_calling/H82_k27ac_peaks_treat_pileup_normalized.bdg"
#BDG3="/hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H524_cMYC/peak_calling/H524_chip_merged_peaks_treat_pileup_normalized.bdg"

OUTPUT="SCLC_N_H3K4me3_pileup_shared_peaks.bdg"

# Use bedtools map to extract pileup values at shared intervals
bedtools map -a "$SHARED_BED" -b "$BDG1" -c 4 -o mean > tmp1.bdg
bedtools map -a "$SHARED_BED" -b "$BDG2" -c 4 -o mean > tmp2.bdg
#bedtools map -a "$SHARED_BED" -b "$BDG3" -c 4 -o mean > tmp3.bdg

# Paste all three and compute average
#paste tmp1.bdg tmp2.bdg tmp3.bdg | \
#awk '{
    #chrom=$1; start=$2; end=$3;
    #val1=$4; val2=$8; val3=$12;
    #if (val1 == ".") val1=0;
    #if (val2 == ".") val2=0;
    #if (val3 == ".") val3=0;
    #avg = (val1 + val2 + val3) / 3;
    #printf "%s\t%s\t%s\t%.6f\n", chrom, start, end, avg;
#}' > "$OUTPUT"
paste tmp1.bdg tmp2.bdg | \
awk '{
    chrom=$1; start=$2; end=$3;
    val1=$4; val2=$8;
    if (val1 == ".") val1=0;
    if (val2 == ".") val2=0;
    avg = (val1 + val2) / 2;
    printf "%s\t%s\t%s\t%.6f\n", chrom, start, end, avg;
}' > "$OUTPUT"

# Clean up temp files
#rm tmp1.bdg tmp2.bdg tmp3.bdg
rm tmp1.bdg tmp2.bdg
