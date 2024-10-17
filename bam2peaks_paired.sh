#! /bin/bash

set -euo pipefail

#cell line 
cell_line=$1
fdr=$2
cd ./${cell_line}
chip_dir=."/${cell_line}_cmyc_chip_woblacklist_rep1.sorted.rmdup.bam"
input_dir=./"${cell_line}_input_woblacklist_rep1.sorted.rmdup.bam"

ml macs/2.1.0
mkdir -p "./peak_calling_new_fdr"
macs2 callpeak -t $chip_dir -c $input_dir -g hs -n "${cell_line}_peaks" -f BAMPE -B --keep-dup 'all' -q ${fdr}
mv ${cell_line}_peaks_control_lambda.bdg ${cell_line}_peaks_peaks.narrowPeak ${cell_line}_peaks_peaks.xls ${cell_line}_peaks_summits.bed ${cell_line}_peaks_treat_pileup.bdg ./peak_calling_new_fdr/
