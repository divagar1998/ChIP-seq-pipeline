library(DiffBind);
library(ggplot2);
library(dplyr);

# Get the file path of the samples.csv from the command-line arguments
# Get the directory path to send output plot files
args <- commandArgs(trailingOnly = TRUE)
sample_file <- args[1]
output_dir <- args[2]

samples <- read.csv(sample_file, header=TRUE)
dba_obj <- dba(sampleSheet = samples)

# Plot correlation heatmap with all peaks
png(filename = file.path(output_dir, "cmyc_comparative_correlation_heatmap2.png"))
plot(dba_obj)
dev.off()

# Calculate binding matrix with read counts
# Divide the reads in chip by reads in input rather than subtract
dba_obj <- dba.count(dba_obj,score=DBA_SCORE_READS_FOLD)

# Normalize the read counts by default with sequencing depth
dba_obj <- dba.normalize(dba_obj)

# Plot PCA
png(filename = file.path(output_dir, "cmyc_comparative_pca5.png"))
dba.plotPCA(dba_obj,DBA_TISSUE)
dev.off()

# Retrieve the count matrix
counts <- dba.peakset(dba_obj, bRetrieve=TRUE, writeFile="diffbind_count_matrix.txt")

# Create the contrast model
dba_obj <- dba.contrast(dba_obj, categories = DBA_CONDITION)
dba_obj <- dba.analyze(dba_obj)
dba.show(dba_obj,bContrasts=TRUE)

# Plot correlation heatmap with differential peaks
png(filename = file.path(output_dir, "cmyc_comparative_correlation_heatmap_differential_NE.png"))
plot(dba_obj,contrast=1)
dev.off()

# Volcano Plot
png(filename = file.path(output_dir, "cmyc_comparative_volcano_NE.png"))
dba.plotVolcano(dba_obj)
dev.off()

# Heatmap
hmap <- colorRampPalette(c("blue", "white", "red"))(n = 13)
png(filename = file.path(output_dir, "cmyc_comparative_heatmap_NE.png"))
dba.plotHeatmap(dba_obj, contrast=1, correlations=FALSE,scale="row", colScheme = hmap)
dev.off()

# Retrieve differentially bound sites
dba_obj.DB <- dba.report(dba_obj)


# Create bed files for each keeping only significant peaks (p < 0.05)
out <- as.data.frame(dba_obj.DB)

non_NE_enrich <- out %>% filter(FDR < 0.05 & Fold > 0) %>% select(seqnames, start, end)
write.table(non_NE_enrich, file="Nanog_enriched.bed", sep="\t", quote=F, row.names=F, col.names=F)

pou5f1_enrich <- out %>% 
  filter(FDR < 0.05 & Fold < 0) %>% 
  select(seqnames, start, end)

# Write to file
write.table(pou5f1_enrich, file="Pou5f1_enriched.bed", sep="\t", quote=F, row.names=F, col.names=F)