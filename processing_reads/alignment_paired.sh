#! /bin/bash
set -euo pipefail

# file path of the reference genome
REF="~/watanabe/ref/grch38_1kgmaj"
# file path of the blacklisted genes
REF_blacklist="~/watanabe/ref/ENCFF356LFX_unified_blacklist_GrCh38.bed"

input_csv=$1

ml bowtie2/2.4.1
ml samtools/1.17
ml bedtools/2.29.0
ml java
ml picard/3.1.1
ml openssl/1.0.2

while IFS="," read -r cell_line;
do
    echo "Processing ${cell_line}"
    # Create arrays to hold R1 and R2 files
    R1_FILES=()
    R2_FILES=()

    # Loop through the files in the directory and separate R1 and R2
    for file in "${cell_line}"/*; do
        if [[ $file == *"_R1_cutadapt.fastq.gz"* ]]; then
            R1_FILES+=("$file")
        elif [[ $file == *"_R2_cutadapt.fastq.gz"* ]]; then
            R2_FILES+=("$file")
        fi
    done

    # Check if the number of R1 and R2 files match
    if [ ${#R1_FILES[@]} -ne ${#R2_FILES[@]} ]; then
        echo "Error: Number of R1 and R2 files do not match!"
        exit 1
    fi

    # Run Bowtie2 for each pair of R1 and R2 files
    for i in "${!R1_FILES[@]}"; do
        R1="${R1_FILES[i]}"
        R2="${R2_FILES[i]}"

        if [ ! -f "${R1%_R1_cutadapt.fastq.gz}_aligned.sam" ]; then
            bowtie2 -p 10 -x $REF -1 "$R1" -2 "$R2" -S "${R1%_R1_cutadapt.fastq.gz}_aligned.sam"
        else        
            echo "${R1%_R1_cutadapt.fastq.gz}_aligned.sam already exists"
        fi

        # convert sam to bam
	    # only take reads that have quality score above 30

        if [ ! -f "${R1%_R1_cutadapt.fastq.gz}.sorted.bam" ]; then
	        samtools view -q 31 -b "${R1%_R1_cutadapt.fastq.gz}_aligned.sam" | samtools sort -@ 10 -T "temp.bam" -o "${R1%_R1_cutadapt.fastq.gz}.sorted.bam"

            # index bam file
	        samtools index "${R1%_R1_cutadapt.fastq.gz}.sorted.bam"
        else    
            echo "${R1%_R1_cutadapt.fastq.gz}.sorted.bam sorted"
        fi
        
        # remove blacklisted regions
        bedtools intersect -abam "${R1%_R1_cutadapt.fastq.gz}.sorted.bam" -b $REF_blacklist -v | samtools sort -@ 10 -o "${R1%_R1_cutadapt.fastq.gz}.woblacklist.sorted.bam" 

        echo "removing duplicates from ${R1%_R1_cutadapt.fastq.gz}.woblacklist.sorted.bam"
        #remove duplicate reads
        java \
        -jar $PICARD \
        MarkDuplicates \
        INPUT="${R1%_R1_cutadapt.fastq.gz}.woblacklist.sorted.bam" \
        OUTPUT="${R1%_R1_cutadapt.fastq.gz}.woblacklist.sorted.rmdup.bam" \
        METRICS_FILE="${R1%_R1_cutadapt.fastq.gz}.woblacklist.sorted.rmdup.txt" \
        REMOVE_DUPLICATES=true

        # remove the sam file 
        rm "${R1%_R1_cutadapt.fastq.gz}_aligned.sam" 

    done

done < ${input_csv}

    
