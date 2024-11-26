#! /bin/bash
set -euo pipefail

# file path of the reference genome
REF="/hpc/users/divagt01/watanabe/ref/grch38_1kgmaj"
# file path of the blacklisted genes
REF_blacklist="/hpc/users/divagt01/watanabe/ref/ENCFF356LFX_unified_blacklist_GrCh38.bed"

input_csv=$1

ml bowtie2
ml samtools/1.17
ml bedtools
ml java
ml picard
ml openssl/1.0.2

while IFS="," read -r cell_line fastq;
do
    cd ${cell_line}
    IFS="," read -r -a fastq_files <<< ${fastq}

    for f in "${fastq_files[@]}"
    do 
        echo "${f}"
        IFS="." read -r -a spl <<< ${f}
        # create sam alignment file
        bowtie2 -p 30 -x $REF -U ${f} -S "${spl}.sam"

        # convert sam to bam
	    # only take reads that have quality score above 30
	    samtools view -q 31 -b "${spl}.sam" | samtools sort -@ 30 -T "temp.bam" -o "${spl}.sorted.bam"

        # index bam file
	    samtools index "${spl}.sorted.bam"

        # remove blacklisted regions
        bedtools intersect -abam "${spl}.sorted.bam" -b $REF_blacklist -v | samtools sort -@ 30 -o "${spl}.woblacklist.sorted.bam" 

        # move the sam file to archives
        mv "${spl}.sam" /sc/arion/scratch/divagt01

        #remove duplicate reads
        java \
        -jar $PICARD \
        MarkDuplicates \
        INPUT="${spl}.woblacklist.sorted.bam" \
        OUTPUT="${spl}.woblacklist.sorted.rmdup.bam" \
        METRICS_FILE="${spl}.woblacklist.sorted.bam.rmdup.txt" \
        REMOVE_DUPLICATES=true
    done

done < ${input_csv}

    
