#! /bin/bash

ml bedtools/2.31.0

# first row has all c-Myc peaks
# second row has all L-Myc peaks
input_csv=$1
output_dir=$2

cd $output_dir

IFS=','
read -r -a c_myc_peaks <<< "$(head -n 1 ${input_csv})"
read -r -a l_myc_peaks <<< "$(sed -n '2p' ${input_csv})"
unset IFS

c_myc_array=($c_myc_peaks)
l_myc_array=($l_myc_peaks)

touch temp_myc.narrowPeak 
touch temp_lmyc.narrowPeak 

for file in ${c_myc_peaks[@]}; do
    cat temp_myc.narrowPeak $file > temp_myc.narrowPeak
done

mv temp_myc.narrowPeak c_myc_all_peaks.narrowPeak
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}' c_myc_all_peaks.narrowPeak > c_myc_all_peaks.bed

for file in ${l_myc_peaks[@]}; do
    cat temp_lmyc.narrowPeak $file > temp_lmyc.narrowPeak
done

mv temp_lmyc.narrowPeak l_myc_all_peaks.narrowPeak
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}' l_myc_all_peaks.narrowPeak > l_myc_all_peaks.bed

sort -k1,1 -k2,2n c_myc_all_peaks.bed > c_myc_all_peaks_sorted.bed
sort -k1,1 -k2,2n l_myc_all_peaks.bed > l_myc_all_peaks_sorted.bed

bedtools merge -i c_myc_all_peaks_sorted.bed > c_myc_all_peaks_sorted_merged.bed
bedtools merge -i l_myc_all_peaks_sorted.bed > l_myc_all_peaks_sorted_merged.bed

bedtools intersect -a c_myc_all_peaks_sorted_merged.bed -b l_myc_all_peaks_sorted_merged.bed > shared_peaks.bed
bedtools subtract -A -a c_myc_all_peaks_sorted_merged.bed -b shared_peaks.bed > unique_cmyc_peaks.bed
bedtools subtract -A -a l_myc_all_peaks_sorted_merged.bed -b shared_peaks.bed > unique_lmyc_peaks.bed

# create a combined c-myc and l-myc bed file for GREAT analysis background region
cat c_myc_all_peaks_sorted_merged.bed l_myc_all_peaks_sorted_merged.bed > c_and_l_myc_peaks.bed
sort -k1,1 -k2,2n c_and_l_myc_peaks.bed > c_and_l_myc_peaks_sorted.bed
bedtools merge -i c_and_l_myc_peaks_sorted.bed > c_and_l_myc_peaks_sorted_merged.bed