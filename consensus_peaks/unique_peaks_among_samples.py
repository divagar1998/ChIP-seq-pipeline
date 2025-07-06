import os
import subprocess

# File paths
A_file = "/hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H2171_cMYC/peak_calling/H2171_chip_merged_peaks_peaks.narrowPeak"
B_file = "/hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H82_cMYC/peak_calling/H82_cMYC_peaks.narrowPeak"
C_file = "/hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H524_cMYC/peak_calling/H524_cMYC_chip_peaks.narrowPeak"

# Sort and create temp sorted files
sorted_A = "H2171_cMYC_sorted.bed"
sorted_B = "H82_cMYC_sorted.bed"
sorted_C = "H524_cMYC_sorted.bed"

# Output overlap files
AB_bed = "H2171_and_H82_cMYC.bed"
AC_bed = "H2171_and_H524_cMYC.bed"
BC_bed = "H82_and_H524_cMYC.bed"
ABC_bed = "H2171_and_H82_and_H524_cMYC.bed"

# Function to sort BED files
def sort_bed(infile, outfile):
    with open(outfile, "w") as out:
        subprocess.run(f"sort -k1,1 -k2,2n {infile}", shell=True, stdout=out)

# Sort input files
sort_bed(A_file, sorted_A)
sort_bed(B_file, sorted_B)
sort_bed(C_file, sorted_C)

# Helper to run bedtools and remove duplicates
def bedtools_intersect(a, b, output):
    tmp_file = "tmp_overlap.bed"
    with open(tmp_file, "w") as out:
        subprocess.run(f"bedtools intersect -a {a} -b {b} -u", shell=True, stdout=out)
    # Remove duplicates and sort
    subprocess.run(f"sort -k1,1 -k2,2n {tmp_file} | uniq > {output}", shell=True)
    os.remove(tmp_file)

# Run intersections
bedtools_intersect(sorted_A, sorted_B, AB_bed)
bedtools_intersect(sorted_A, sorted_C, AC_bed)
bedtools_intersect(sorted_B, sorted_C, BC_bed)

# A ∩ B ∩ C
tmp_abc = "tmp_abc.bed"
with open(tmp_abc, "w") as out:
    subprocess.run(f"bedtools intersect -a {AB_bed} -b {sorted_C} -u", shell=True, stdout=out)
subprocess.run(f"sort -k1,1 -k2,2n {tmp_abc} | uniq > {ABC_bed}", shell=True)
os.remove(tmp_abc)

# Count lines
def count_lines(file):
    with open(file) as f:
        return sum(1 for _ in f)

# Total regions
total_A = count_lines(sorted_A)
total_B = count_lines(sorted_B)
total_C = count_lines(sorted_C)
count_AB = count_lines(AB_bed)
count_AC = count_lines(AC_bed)
count_BC = count_lines(BC_bed)
count_ABC = count_lines(ABC_bed)

# Calculate Venn subsets
only_A = total_A - count_AB - count_AC + count_ABC
only_B = total_B - count_AB - count_BC + count_ABC
only_C = total_C - count_AC - count_BC + count_ABC
AB = count_AB - count_ABC
AC = count_AC - count_ABC
BC = count_BC - count_ABC
ABC = count_ABC

# Print summary
print(f"Unique to A: {only_A}")
print(f"Unique to B: {only_B}")
print(f"Unique to C: {only_C}")
print(f"A ∩ B only: {AB}   --> saved to {AB_bed}")
print(f"A ∩ C only: {AC}   --> saved to {AC_bed}")
print(f"B ∩ C only: {BC}   --> saved to {BC_bed}")
print(f"A ∩ B ∩ C: {ABC}   --> saved to {ABC_bed}")

# Output the unique BED files for each group
unique_A_bed = "unique_H2171_cMYC_peaks.bed"
unique_B_bed = "unique_H82_cMYC_peaks.bed"
unique_C_bed = "unique_H524_cMYC_peaks.bed"

# Extract unique regions from each
subprocess.run(f"bedtools intersect -v -a {sorted_A} -b {AB_bed} -b {AC_bed} -b {ABC_bed} > {unique_A_bed}", shell=True)
subprocess.run(f"bedtools intersect -v -a {sorted_B} -b {AB_bed} -b {BC_bed} -b {ABC_bed} > {unique_B_bed}", shell=True)
subprocess.run(f"bedtools intersect -v -a {sorted_C} -b {AC_bed} -b {BC_bed} -b {ABC_bed} > {unique_C_bed}", shell=True)

print(f"Unique peaks for H2171 saved to: {unique_A_bed}")
print(f"Unique peaks for H82 saved to: {unique_B_bed}")
print(f"Unique peaks for H524 saved to: {unique_C_bed}")
