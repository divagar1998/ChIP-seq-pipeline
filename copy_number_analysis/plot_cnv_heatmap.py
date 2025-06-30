# in terminal start cnvkit_env using conda
import matplotlib.pyplot as plt
import cnvlib
import argparse

myc_amp_cell_filenames = [
    "NCIH2081_CCLE_hg38.cns",
    "H2081_input.cns",
    "NCIH2171_CCLE_hg38.cns",
    "H2171_input.cns",
    "NCIH82_CCLE_hg38.cns",
    "H82_input.cns",
    "NCIH524_CCLE_hg38.cns",
    "H524_input.cns",
]

mycl_amp_cell_filenames = [
    "CORL88_CCLE_hg38.cns",
    "CORL88_input.cns",
    "NCIH209_CCLE_hg38.cns",
    "H209_input.cns"
]

parser = argparse.ArgumentParser()
parser.add_argument("--path_for_files")
parser.add_argument("--path_to_save_plots")
args = parser.parse_args()


myc_amp_cell_filenames = [args.path_for_files + f for f in myc_amp_cell_filenames]
mycl_amp_cell_filenames = [args.path_for_files + f for f in mycl_amp_cell_filenames]


# Read CNV segments from files
myc_amp_cell_segments = [cnvlib.read(f) for f in myc_amp_cell_filenames]
mycl_amp_cell_segments = [cnvlib.read(f) for f in mycl_amp_cell_filenames]

# MYC coordinates
myc_start = 127736231
myc_end = 127742951
buffer = 30000  # ±30 KB
region_start = myc_start - buffer
region_end = myc_end + buffer
region = ('chr8', region_start, region_end)

fig, ax = plt.subplots(figsize=(6, 3))

# Plot CNV heatmap in the region
cnvlib.heatmap.do_heatmap(myc_amp_cell_segments, show_range=region, ax=ax)
xlim = ax.get_xlim()

myc_start_normalized = (myc_start - region_start) / (region_end - region_start) * (xlim[1] - xlim[0]) + xlim[0]
myc_end_normalized = (myc_end - region_start) / (region_end - region_start) * (xlim[1] - xlim[0]) + xlim[0]

# Add vertical lines at actual MYC coordinates
ax.axvline(myc_start_normalized, color='black', linestyle='--', label='MYC locus')
ax.axvline(myc_end_normalized, color='black', linestyle='--', label=None)

ax.set_title("MYC Locus CNV ±30KB")
ax.set_xlabel("Genomic position at chr 8(bp)")
ax.legend(fontsize=8)

sample_names = [segment.sample_id for segment in myc_amp_cell_segments] 
ax.set_yticks(range(len(sample_names)))  
ax.set_yticklabels(sample_names) 

plt.tight_layout()
output_filename = f"{args.path_to_save_plots}MYC_CNV_heatmap_chr8.png"
plt.savefig(output_filename, dpi=600)
