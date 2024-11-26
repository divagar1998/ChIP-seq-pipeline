#! /bin/bash

ml bedgraphtobigwig/2018-01-30

input_csv=$1
chrom_size=$2

# CSV file has one column for bw file name, 
# one column of path of bedgraph files,
# one column of directory to ouput bw file
while IFS=, read -r col1 col2 col3; do
    cd $col3
    # Sort the bedgraph file chromosome number and chromosome position
    sort -k1,1 -k2,2n $col2 > temp.bdg

    bedGraphToBigWig temp.bdg $2 "${col1}.bw"

    rm temp.bdg
    
done < $1


