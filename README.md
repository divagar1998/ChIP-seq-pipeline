# ChIP-seq-pipeline

Contains the pipeline that I use to analyze my own ChIP-seq data with c-Myc, L-Myc, H3K27ac and H3K27me3 antibodies as well as publicly available c-Myc ChIP-seq data

This repository only contains the scripts of the pipeline. The data and plots are in a private repository.

## deeptools_analysis
`multimodal_chip_integration.sh` is used to plot the profile of peaks of TF chip, H3K27ac and H3K27me3 chip for visualisation of multimodal information given a common reference peakset. The reference peaksets are unique c-Myc binding sites, unique L-Myc binding sites and common binding sites. 
`myc_chip_clustering.sh` used to plot the profile of peaks of TF chip after k-means clustering of their combined peakset.

## diffbind_analysis
`myc_cistrome_diffbind.R` uses the DiffBind Bioconductor package to perform differential analysis of c-Myc cistromes from multiple c-Myc amplified cell lines. Analyses include plotting correlation heatmaps, PCA plots and identifying differentially bound sites.
`sclc_myc_mycl_chip_diffanalysis.R` ses the DiffBind Bioconductor package to perform differential analysis of c-Myc and L-Myc cistromes from SCLC cell lines. Analyses include plotting correlation heatmaps, PCA plots and identifying differentially bound sites.

## processing_reads
Contain scripts used to process raw sequencing read files (fastq) until peak calling step with MACS2. The pipeline briefly is scrape the fastq file with `sratoolkit`--> gzip fastq file --> perform QC with `fastqc` --> remove adapters with `cutadapt` --> repeat QC to check if adapters are removed --> align `fastq.gz` files to hg38 with `bowtie2` --> convert `sam` file to `bam` file with `samtools` --> remove alignments to blacklisted regions with `bedtools intersect` --> remove duplicated alignments with `picard` --> call peaks with `macs2` --> create coverage files with `bedgraphtobigwig`

## qc_checks
Contains scripts to measure reproducibility between 3 replicates performed on every of my ChIP-seq for each cellline. IDR python package is used. 