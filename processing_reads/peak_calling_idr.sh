#! /bin/bash
set -euo pipefail

input_csv=$1

ml macs/2.1.0

while IFS=, read -r cell_line;
do
    cd "$cell_line"
    INPUT_FILE=()
    CHIP_FILES=()
    for bamfile in *woblacklist.sorted.rmdup.bam;
    do 
        if [[ $bamfile == *"input"* ]]; then
            INPUT_FILE+=("$bamfile")
        else
        CHIP_FILES+=("$bamfile")
        fi
    done

    for bamfile in "${CHIP_FILES[@]}";
    do
        label="${bamfile%.woblacklist.sorted.rmdup.bam}"
        macs2 callpeak -t $bamfile -c $INPUT_FILE -g hs -n "${label}_peaks" -f BAMPE -B --keep-dup 'all' -p 1e-3
        mkdir -p ./peaks_idr
        mv *${label}_peaks* ./peaks_idr
    done
done < $input_csv