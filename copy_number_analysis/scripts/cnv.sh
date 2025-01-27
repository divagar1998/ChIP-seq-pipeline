#! /bin/bash

bamfile=$1
genome_access_file=$2

# refFlat.hg38.txt for me
# annotation file cannot be gzipped
annotation=$3
reference_cnn=$4
output_folder=$5

sample_name=$(basename "$bamfile" .bam)

cnvkit.py batch $bamfile \
        -m wgs -r $reference_cnn -p 8 \
        --output-dir $output_folder \
        --diagram --scatter

#cnvkit.py autobin $bamfile -m wgs -g $genome_access_file --annotate $annotation
#cnvkit.py coverage $bamfile "${sample_name}.target.bed" -o "${sample_name}.targetcoverage.cnn"
#cnvkit.py coverage $bamfile "${sample_name}.antitarget.bed" -o "${sample_name}.antitargetcoverage.cnn"
#cnvkit.py fix "${sample_name}.targetcoverage.cnn" "${sample_name}.antitargetcoverage.cnn" $reference_cnn -o "${sample_name}.cnr"
#cnvkit.py segment "${sample_name}.cnr" -o "${sample_name}.cns"
#cnvkit.py diagram "${sample_name}.cnr" -s "${sample_name}.cns" -o "${sample_name}_diagram.pdf"

