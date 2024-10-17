#! /bin/bash

set -euo pipefail

#cell line 
cell_line=$1
cd ./${cell_line}
chip_dir=."/${cell_line}_cmyc_chip_woblacklist.sorted.rmdup.bam"
input_dir=./"${cell_line}_input_woblacklist.sorted.rmdup.bam"

ml macs/2.1.0

macs2 callpeak --cutoff-analysis -t $chip_dir -c $input_dir -g hs -n "${cell_line}_peaks_cutoff_analysis" -f BAMPE -B --keep-dup 'all'
