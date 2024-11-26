#! /bin/bash


input_csv=$1

ml macs/2.1.0

while IFS=, read -r col1 col2 col3 col4 input; do
    cd $col1
    mkdir -p peak_calling_idr
    macs2 callpeak \
    -t $col2 \
    -c $input \
    -g hs -n "H2171_br1_idr_peaks" \
    -f BAMPE -B \
    --keep-dup 'all' \
    -q 0.15 \
    --outdir peak_calling_idr

    macs2 callpeak \
    -t $col3 \
    -c $input \
    -g hs -n "H2171_br2_idr_peaks" \
    -f BAMPE -B \
    --keep-dup 'all' \
    -q 0.15 \
    --outdir peak_calling_idr

    macs2 callpeak \
    -t $col4 \
    -c $input \
    -g hs -n "H2171_br3_idr_peaks" \
    -f BAMPE -B \
    --keep-dup 'all' \
    -q 0.15 \
    --outdir peak_calling_idr
done < $input_csv
