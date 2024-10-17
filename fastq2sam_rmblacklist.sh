#! /bin/bash
set -euo pipefail

cell_line=$1
chip_fastq_file=$2
input_fastq_file=$3

# file path of the reference genome
REF="/hpc/users/divagt01/watanabe/ref/grch38_1kgmaj"
# file path of the blacklisted genes
REF_blacklist="/hpc/users/divagt01/watanabe/ref/ENCFF356LFX_unified_blacklist_GrCh38.bed"
# REF_blacklist="blacklist_hg38.bed"

ml bowtie2

# check if sam file already exists
if [ -e ./"${cell_line}"/"${cell_line}_cmyc_chip".sam ]
then
	echo "cmyc_chip sam file exists"
else
	echo "cmyc_chip sam file does not exist"
	# align the reads with bowtie2
	bowtie2 -p 32 -x $REF -U ./"${cell_line}"/"${chip_fastq_file}".fastq.gz -S ./"${cell_line}"/"${cell_line}_cmyc_chip".sam
fi

if [ -e ./"${cell_line}"/"${cell_line}_input".sam ]
then
	echo "input sam file exists"
else
	echo "input sam file does not exist"
	# align the reads with bowtie2
	bowtie2 -p 32 -x $REF -U ./"${cell_line}"/"${input_fastq_file}".fastq.gz -S ./"${cell_line}"/"${cell_line}_input".sam
fi

echo "sam files created"

ml samtools
ml bedtools

# check if sorted bam file exists
if [ -e ./"${cell_line}"/"${cell_line}_cmyc_chip".sorted.bam ]
then
	echo "sorted bam file for cmyc_chip exists"
else
	echo "sorted bam file for cmyc_chip does not exist"
	# convert sam to bam
	# only take reads that have quality score above 30
	samtools view -q 30 -b ./"${cell_line}"/"${cell_line}_cmyc_chip".sam | samtools sort -@ 31 -T ./"${cell_line}"/"${cell_line}_cmyc_chip" -o ./"${cell_line}"/"${cell_line}_cmyc_chip".sorted.bam
	# index bam file
	samtools index ./"${cell_line}"/"${cell_line}_cmyc_chip".sorted.bam
fi

if [ -e ./"${cell_line}"/"${cell_line}_input".sorted.bam ]
then
	echo "sorted bam file for input exists"
else
	echo "sorted bam file for input does not exist"
	samtools view -q 30 -b ./"${cell_line}"/"${cell_line}_input".sam | samtools sort -@ 31 -T ./"${cell_line}"/"${cell_line}_input" -o ./"${cell_line}"/"${cell_line}_input".sorted.bam
	# index bam file
	samtools index ./"${cell_line}"/"${cell_line}_input".sorted.bam
fi

echo "sorted bam files created"
echo "bam files indexed"

# remove blacklisted regions
bedtools intersect -abam ./"${cell_line}"/"${cell_line}_cmyc_chip".sorted.bam -b $REF_blacklist -v | samtools sort -@ 31 -o ./"${cell_line}"/"${cell_line}_cmyc_chip_woblacklist".sorted.bam
bedtools intersect -abam ./"${cell_line}"/"${cell_line}_input".sorted.bam -b $REF_blacklist -v | samtools sort -@ 31 -o ./"${cell_line}"/"${cell_line}_input_woblacklist".sorted.bam
echo "blacklist genes removed"

# move the sam file to archives
mv ./"${cell_line}"/"${cell_line}_cmyc_chip".sam /sc/arion/scratch/divagt01
mv ./"${cell_line}"/"${cell_line}_input".sam /sc/arion/scratch/divagt01
