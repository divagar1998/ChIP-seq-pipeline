#! /bin/bash

computeMatrix reference-point \
    -S /hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H82_Patel2021/peak_calling/H82_Patel2021_ATAC_peaks_treat_pileup.bw /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H82/peak_calling/H82_chip.bw \
    -R /hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H82_Patel2021/peak_calling/H82_Patel2021_ATAC_peaks_peaks.narrowPeak /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H82/peak_calling/H82_chip_merged_peaks_peaks.narrowPeak \
    -a 3000 -b 3000 \
    --referencePoint TSS \
    --skipZeros \
    --missingDataAsZero \
    --binSize 10 \
    --sortRegions no \
    --numberOfProcessors 12 \
    --outFileName matrix_file.gz 

plotHeatmap \
    -m /hpc/users/divagt01/watanabe/Divagar/ChIP-seq-pipeline/deeptools_analysis/matrix_file.gz \
    -out heatmap3.png \
    --sortUsing mean \
    --averageTypeSummaryPlot mean \
    --missingDataColor "#440154" \
    --colorMap viridis \
    --zMax 100 \
    --linesAtTickMarks \
    --refPointLabel "TSS" \
    --heatmapHeight 20 \
    --heatmapWidth 10 \
    --dpi 300




