#! /bin/bash
set -euo pipefail

cell_line=$1
chip_fastq_mate1_file_rep1=$2
chip_fastq_mate2_file_rep1=$3
chip_fastq_mate1_file_rep2=$4
chip_fastq_mate2_file_rep2=$5
input_fastq_mate1_file_rep1=$6
input_fastq_mate2_file_rep1=$7
input_fastq_mate1_file_rep2=$8
input_fastq_mate2_file_rep2=$9

# file path of the reference genome
REF="/hpc/users/divagt01/watanabe/ref/grch38_1kgmaj"
# file path of the blacklisted genes
REF_blacklist="/hpc/users/divagt01/watanabe/ref/ENCFF356LFX_unified_blacklist_GrCh38.bed"
# REF_blacklist="blacklist_hg38.bed"

ml bowtie2

# check if sam file already exists
if [ -e ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sam ]
then
	echo "cmyc_chip sam file exists"
else
	echo "cmyc_chip sam file does not exist"
	# align the reads with bowtie2
	bowtie2 -p 32 -x $REF -1 ./"${cell_line}"/"${chip_fastq_mate1_file_rep1}".fastq.gz -2 ./"${cell_line}"/"${chip_fastq_mate2_file_rep1}".fastq.gz  -S ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sam
fi

if [ -e ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sam ]
then
	echo "cmyc_chip sam file exists"
else
	echo "cmyc_chip sam file does not exist"
	# align the reads with bowtie2
	bowtie2 -p 32 -x $REF -1 ./"${cell_line}"/"${chip_fastq_mate1_file_rep2}".fastq.gz -2 ./"${cell_line}"/"${chip_fastq_mate2_file_rep2}".fastq.gz  -S ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sam
fi

if [ -e ./"${cell_line}"/"${cell_line}_input_rep1".sam ]
then
	echo "input sam file exists"
else
	echo "input sam file does not exist"
	# align the reads with bowtie2
	bowtie2 -p 32 -x $REF -1 ./"${cell_line}"/"${input_fastq_mate1_file_rep1}".fastq.gz -2 ./"${cell_line}"/"${input_fastq_mate2_file_rep1}".fastq.gz  -S ./"${cell_line}"/"${cell_line}_input_rep1".sam
fi

if [ -e ./"${cell_line}"/"${cell_line}_input_rep2".sam ]
then
	echo "input sam file exists"
else
	echo "input sam file does not exist"
	# align the reads with bowtie2
	bowtie2 -p 32 -x $REF -1 ./"${cell_line}"/"${input_fastq_mate1_file_rep2}".fastq.gz -2 ./"${cell_line}"/"${input_fastq_mate2_file_rep2}".fastq.gz  -S ./"${cell_line}"/"${cell_line}_input_rep2".sam
fi

echo "sam files created"

ml samtools
ml bedtools

# check if sorted bam file exists
if [ -e ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sorted.bam ]
then
	echo "sorted bam file for cmyc_chip exists"
else
	echo "sorted bam file for cmyc_chip does not exist"
	# convert sam to bam
	# only take reads that have quality score above 30
	samtools view -q 30 -b ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sam | samtools sort -@ 31 -T ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1" -o ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sorted.bam
	# index bam file
	samtools index ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sorted.bam
fi

# check if sorted bam file exists
if [ -e ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sorted.bam ]
then
	echo "sorted bam file for cmyc_chip exists"
else
	echo "sorted bam file for cmyc_chip does not exist"
	# convert sam to bam
	# only take reads that have quality score above 30
	samtools view -q 30 -b ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sam | samtools sort -@ 31 -T ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2" -o ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sorted.bam
	# index bam file
	samtools index ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sorted.bam
fi

if [ -e ./"${cell_line}"/"${cell_line}_input_rep1".sorted.bam ]
then
	echo "sorted bam file for input exists"
else
	echo "sorted bam file for input does not exist"
	samtools view -q 30 -b ./"${cell_line}"/"${cell_line}_input_rep1".sam | samtools sort -@ 31 -T ./"${cell_line}"/"${cell_line}_input_rep1" -o ./"${cell_line}"/"${cell_line}_input_rep1".sorted.bam
	# index bam file
	samtools index ./"${cell_line}"/"${cell_line}_input_rep1".sorted.bam
fi

if [ -e ./"${cell_line}"/"${cell_line}_input_rep2".sorted.bam ]
then
	echo "sorted bam file for input exists"
else
	echo "sorted bam file for input does not exist"
	samtools view -q 30 -b ./"${cell_line}"/"${cell_line}_input_rep2".sam | samtools sort -@ 31 -T ./"${cell_line}"/"${cell_line}_input_rep2" -o ./"${cell_line}"/"${cell_line}_input_rep2".sorted.bam
	# index bam file
	samtools index ./"${cell_line}"/"${cell_line}_input_rep2".sorted.bam
fi

echo "sorted bam files created"
echo "bam files indexed"

# remove blacklisted regions
bedtools intersect -abam ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sorted.bam -b $REF_blacklist -v | samtools sort -@ 31 -o ./"${cell_line}"/"${cell_line}_cmyc_chip_woblacklist_rep1".sorted.bam
bedtools intersect -abam ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sorted.bam -b $REF_blacklist -v | samtools sort -@ 31 -o ./"${cell_line}"/"${cell_line}_cmyc_chip_woblacklist_rep2".sorted.bam
bedtools intersect -abam ./"${cell_line}"/"${cell_line}_input_rep1".sorted.bam -b $REF_blacklist -v | samtools sort -@ 31 -o ./"${cell_line}"/"${cell_line}_input_woblacklist_rep1".sorted.bam
bedtools intersect -abam ./"${cell_line}"/"${cell_line}_input_rep2".sorted.bam -b $REF_blacklist -v | samtools sort -@ 31 -o ./"${cell_line}"/"${cell_line}_input_woblacklist_rep2".sorted.bam
echo "blacklist genes removed"

# move the sam file to archives
mv ./"${cell_line}"/"${cell_line}_cmyc_chip_rep1".sam /sc/arion/scratch/divagt01
mv ./"${cell_line}"/"${cell_line}_cmyc_chip_rep2".sam /sc/arion/scratch/divagt01
mv ./"${cell_line}"/"${cell_line}_input_rep1".sam /sc/arion/scratch/divagt01
mv ./"${cell_line}"/"${cell_line}_input_rep2".sam /sc/arion/scratch/divagt01

sorted_bam_file_names=([1]=./"${cell_line}"/"${cell_line}_cmyc_chip_woblacklist_rep1" [2]=./"${cell_line}"/"${cell_line}_cmyc_chip_woblacklist_rep2" [3]=./"${cell_line}"/"${cell_line}_input_woblacklist_rep1" [4]=./"${cell_line}"/"${cell_line}_input_woblacklist_rep2")

# remove duplicates from bam file
ml java
ml picard
for i in "${sorted_bam_file_names[@]}"
do 
	java \
	-jar $PICARD \
	MarkDuplicates \
	INPUT="${i}".sorted.bam \
	OUTPUT="${i}".sorted.rmdup.bam \
	METRICS_FILE="${i}".sorted.bam.rmdup.txt \
	REMOVE_DUPLICATES=true 
done
