#! /bin/bash

# run script in cnvkit_env with conda

# hg38.fa path
hg38=$1
# blacklist path
# ENCFF356LFX_unified_blacklist_GrCh38.bed for me
blacklist=$2

cnvkit.py access $hg38 -x $blacklist -o ./output/hg38_access.bed