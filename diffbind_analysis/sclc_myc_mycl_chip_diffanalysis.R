library(DiffBind);
library(ggplot2);

# Get the file path of the samples.csv from the command-line arguments
# Get the directory path to send output plot files
args <- commandArgs(trailingOnly = TRUE)
sample_file <- args[2]

samples <- read.csv(sample_file, header=TRUE)
dba_obj <- dba(sampleSheet = samples)

# Plot correlation heatmap with all peaks
png(filename = file.path(output_dir, "plot1.png"))
plot(dba_obj)
dev.off()

# Calculate binding matrix with read counts
dba_obj <- dba.count(dba_obj)

# Normalize the read counts by default with sequencing depth
dba_obj <- dba.normalize(dba_obj)

# Create the contrast model
dba_obj <- dba.contrast(dba_obj, categories = DBA_CONDITION)

# Plot PCA
png(filename = file.path(output_dir, "pca2.png"))
pca_loadings <- dba.plotPCA(dba_obj,DBA_FACTOR,label=DBA_ID)
dev.off()

# Retrieve peaks
peak_set <- dba.peakset(dba_obj, bRetrieve=TRUE)

