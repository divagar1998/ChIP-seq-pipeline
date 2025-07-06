import os
import subprocess
from matplotlib import pyplot as plt
from matplotlib_venn import venn3, venn3_circles

# File paths
A_file = "/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H2171_Patel2021/peak_calling/H2171_Patel2021_ATAC_peaks_peaks.narrowPeak"
B_file = "/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H82_Patel2021/peak_calling/H82_Patel2021_ATAC_peaks_peaks.narrowPeak"
C_file = "/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H524_Patel2021/peak_calling/H524_Patel2021_ATAC_peaks_peaks.narrowPeak"

# Sort and create temp sorted files
sorted_A = "H2171_ATAC_sorted.bed"
sorted_B = "H82_ATAC_sorted.bed"
sorted_C = "H524_ATAC_sorted.bed"

# Output overlap files
AB_bed = "H2171_and_H82_ATAC.bed"
AC_bed = "H2171_and_H524_ATAC.bed"
BC_bed = "H82_and_H524_ATAC.bed"
ABC_bed = "H2171_and_H82_and_H524_ATAC.bed"

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

# Plot Venn diagram
venn = venn3(subsets=(only_A, only_B, AB, only_C, AC, BC, ABC), set_labels=('H2171', 'H82', 'H524'))


overlap_ids = ['110', '101', '011', '111']  # At least 2 overlaps
unique_ids = ['100', '010', '001']          # Unique to A, B, or C

# Set region colors
for subset_id in overlap_ids:
    patch = venn.get_patch_by_id(subset_id)
    if patch:
        patch.set_facecolor('#90EE90')  # light green
        patch.set_edgecolor('black')
        patch.set_linewidth(2)

for subset_id in unique_ids:
    patch = venn.get_patch_by_id(subset_id)
    if patch:
        patch.set_facecolor('#FFCCCB')  # light red
        patch.set_edgecolor('black')
        patch.set_linewidth(2)

# Bold labels
for label in venn.set_labels:
    if label:
        label.set_fontweight('bold')

for label in venn.subset_labels:
    if label:
        label.set_fontweight('bold')

plt.title("ATAC Shared Peaks in SCLC-N")
plt.tight_layout()
plt.savefig("ATAC_peak_venn.png",dpi=600)

combined_shared_bed = "SCLC_N_ATAC_shared_peaks.bed"

# Combine AB, AC, BC, ABC into one file, remove duplicates
subprocess.run(
    f"cat {AB_bed} {AC_bed} {BC_bed} {ABC_bed} | sort -k1,1 -k2,2n | uniq > {combined_shared_bed}",
    shell=True
)
