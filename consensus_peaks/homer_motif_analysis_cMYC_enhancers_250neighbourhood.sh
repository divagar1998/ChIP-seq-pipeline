#! /bin/bash

ml homer

# De novo motif analysis for on cMYC enhancer regions in the 500 bp neighborhood of the peaks

for bed in *_enhancers.bed; do
    outdir="${bed%.bed}_homer_250"
    findMotifsGenome.pl "$bed" hg38 "$outdir" -size 250 -mask -p 10 -h -preparsedDir ./preparsed
done
