#! /bin/bash

ml homer/4.10

annotatePeaks.pl \
    /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/consensus_peaks_files/unique_lmyc_peaks.bed \
    hg38 \
    -annStats unique_lmyc_peaks_stats.txt > unique_lmyc_peaks_annotated.txt

