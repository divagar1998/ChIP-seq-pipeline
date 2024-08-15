#! /bin/bash
set -euo pipefail

chip_fastq_mate1_file=$1
chip_fastq_mate2_file=$2
input_fastq_mate1_file=$3
input_fastq_mate2_file=$4
chip_sam_file=$5
input_sam_file=$6
chip_sortedbam_file=$7
input_sortedbam_file=$8
chip_sortedbam_woblacklist_file=$9
input_sortedbam_woblacklist_file=${10}

# file path of the reference genome
REF="/hpc/users/divagt01/watanabe/ref/grch38_1kgmaj"
# file path of the blacklisted genes
REF_blacklist="/hpc/users/divagt01/watanabe/ref/ENCFF356LFX_unified_blacklist_GrCh38.bed"
# REF_blacklist="blacklist_hg38.bed"

ml bowtie2


bowtie2 -p 32 -x $REF -1 ${chip_fastq_mate1_file} -2 ${chip_fastq_mate2_file}  -S ${chip_sam_file}

bowtie2 -p 32 -x $REF -1 ${input_fastq_mate1_file} -2 ${input_fastq_mate2_file}  -S ${input_sam_file}


echo "sam files created"

ml samtools
ml bedtools

# convert sam to bam
# only take reads that have quality score above 30
samtools view -q 30 -b ${chip_sam_file} | samtools sort -@ 31 -T ./temp -o ${chip_sortedbam_file}
# index bam file
samtools index ${chip_sortedbam_file}

samtools view -q 30 -b ${input_sam_file} | samtools sort -@ 31 -T ./temp -o ${input_sortedbam_file}
# index bam file
samtools index ${input_sortedbam_file}


echo "sorted bam files created"
echo "bam files indexed"

# remove blacklisted regions
bedtools intersect -abam ${chip_sortedbam_file} -b $REF_blacklist -v | samtools sort -@ 31 -o ${chip_sortedbam_woblacklist_file}
bedtools intersect -abam ${input_sortedbam_file} -b $REF_blacklist -v | samtools sort -@ 31 -o ${input_sortedbam_woblacklist_file}
echo "blacklist genes removed"

# move the sam file to archives
mv ${chip_sam_file} /sc/arion/scratch/divagt01
mv ${input_sam_file} /sc/arion/scratch/divagt01
