#! /bin/bash

computeMatrix reference-point \
    -S /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/COLO668/peak_calling/COLO668_chip.bw /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H889/peak_calling/H889_chip.bw /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H2171/peak_calling/H2171_chip.bw /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H82/peak_calling/H82_chip.bw /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H524/peak_calling/H524_chip.bw \
    -R /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/consensus_peaks_files/c_and_l_myc_peaks_sorted_merged.bed \
    -a 3000 -b 3000 \
    --referencePoint center \
    --skipZeros \
    --missingDataAsZero \
    --binSize 10 \
    --numberOfProcessors 12 \
    --outFileName matrix_file_kmeans.gz \
    --samplesLabel COLO668 H889 H2171 H82 H524

plotHeatmap \
    -m matrix_file_chip.gz \
    -out chip1.png \
    --outFileSortedRegions sorted.bed \
    --dpi 720 \
    --missingDataColor White \
    --colorMap Reds \
    --regionsLabel unique_cmyc_peaks unique_Lmyc_peaks shared_peaks \
    --heatmapHeight 13
