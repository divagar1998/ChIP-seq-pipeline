#! /bin/bash
set -euo pipefail

# file path of the reference genome
REF="~/watanabe/ref/grch38_1kgmaj"
# file path of the blacklisted genes
REF_blacklist="~/watanabe/ref/ENCFF356LFX_unified_blacklist_GrCh38.bed"

input_csv=$1

ml bowtie2
ml samtools/1.17
ml bedtools
ml java
ml picard
ml openssl/1.0.2

while IFS="," read -r cell_line;
do
    # Create arrays to hold fastq files
    FASTQ_FILES=()

    # Loop through the files in the directory
    for file in "${cell_line}"/*; do
        if [[ $file == *".fastq.gz"* ]]; then
            FASTQ_FILES+=("$file")
        fi
    done

    for i in "${!FASTQ_FILES[@]}"; do
        f="${FASTQ_FILES[i]}"
        echo "${f}"

        if [ ! -f "${f%_cutadapt.fastq.gz}_aligned.sam" ]; then
            bowtie2 -p 10 -x $REF -U ${f} -S "${f%_cutadapt.fastq.gz}_aligned.sam"
        else        
            echo "${f%_cutadapt.fastq.gz}_aligned.sam already exists"
        fi

        # convert sam to bam
	    # only take reads that have quality score above 30
	    samtools view -q 31 -b "${f%_cutadapt.fastq.gz}_aligned.sam" | samtools sort -@ 10 -T "temp.bam" -o "${f%_cutadapt.fastq.gz}.sorted.bam"

        # index bam file
	    samtools index "${f%_cutadapt.fastq.gz}.sorted.bam"

        # remove blacklisted regions
        bedtools intersect -abam "${f%_cutadapt.fastq.gz}.sorted.bam" -b $REF_blacklist -v | samtools sort -@ 10 -o "${f%_cutadapt.fastq.gz}.woblacklist.sorted.bam" 

        #remove duplicate reads
        java \
        -jar $PICARD \
        MarkDuplicates \
        INPUT="${f%_cutadapt.fastq.gz}.woblacklist.sorted.bam" \
        OUTPUT="${f%_cutadapt.fastq.gz}.woblacklist.sorted.rmdup.bam" \
        METRICS_FILE="${f%_cutadapt.fastq.gz}.woblacklist.sorted.rmdup.txt" \
        REMOVE_DUPLICATES=true

        # remove the sam file 
        rm "${f%_cutadapt.fastq.gz}_aligned.sam" 

    done

done < ${input_csv}

    
