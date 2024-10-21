# Processing Reads
This directory contains scripts that were used to generate peak files from raw fastq files from GEO as well as fastq files that I generated. 

## FASTQ file processing
These scripts were used to scrape fastq files from GEO, perform quality control and remove adapter sequences if any. 
`fastq_get_pairedend_noadaptor.sh` Scrapes paired end fastq files from GEO given a CSV file with SRR run numbers
`fastq_get_singleend_noadaptor.sh` Scrapes single end fastq files from GEO given a CSV file with SRR run numbers
`fastqc.sh` Performs quality control analysis on fastq files given a CSV file with file paths
`removeadaptor_pairedend.sh` Removes adapters from paired end fastq files given a CSV file with file paths and adapter sequences
`removeadaptor_singleend.sh` Removes adapters from single end fastq files given a CSV file with file paths and adapter sequences

## Alignment
These scripts were used to align processed fastq files to hg38 human genome
`fastq2sam_rmblacklist.sh` Aligns single end fastq files to hg38 given a CSV file with file paths to ChIP fastq and input fastq. Removes alignments to blacklisted regions. 
`fastq_paired_2bam_rmblacklist.sh` Aligns pair end fastq files to hg38 given a CSV file with file paths to ChIP fastq and input fastq. Removes alignments to blacklisted regions.

## Peak calling
These scripts were used to call peaks from alignment files using MACS2
`bam2peaks.sh` Calls peaks from single end ChIP and input bam files
`bam2peaks_paired.sh` Calls peaks from paired end ChIP and input bam files
