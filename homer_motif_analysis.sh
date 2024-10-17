#! /bin/bash
set -euo pipefail

ml proxies
ml homer

cell_line=$1
rep=$2
narrowpeak_file_name=$3
cd ./"${cell_line}"

#create file for homer analysis

if [ -e "${cell_line}_${rep}_homer.txt" ] 
then 
    echo "homer text file exists"
else
    cat "${narrowpeak_file_name}" | cut -f 1-4 > "${cell_line}_${rep}_homer.txt"
fi

findMotifsGenome.pl "${cell_line}_${rep}_homer.txt" hg38 ./homer_results/ -size 50 -preparsedDir ./homer_results/

