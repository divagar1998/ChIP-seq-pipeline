#! /bin/bash
# activate deeptools_env
ml samtools

input_csv=$1

# CSV file has one column for bam file path, 

while IFS=, read -r col1; do
    samtools index $col1
    file_name="${col1%.woblacklist.sorted.rmdup.bam}"
    bamCoverage --bam $col1 -o "${file_name}_SeqDepthNorm.bw" \
        --binSize 10 \
        --normalizeUsing RPGC \
        --effectiveGenomeSize 2913022398 \
        --ignoreForNormalization chrX \
        -p 5 \
        --extendReads    
done < ${input_csv}


