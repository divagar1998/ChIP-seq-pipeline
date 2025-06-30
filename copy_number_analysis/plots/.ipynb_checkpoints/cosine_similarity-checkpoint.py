import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

# Load CNS files
df1 = pd.read_csv("CORL88_CCLE_hg38.cns", sep="\t")
df2 = pd.read_csv("CORL88_input.cns", sep="\t")

# Keep only necessary columns
df1 = df1[["chromosome", "start", "end", "log2"]]
df2 = df2[["chromosome", "start", "end", "log2"]]

# Combine all bin edges to create unified bins
all_bins = pd.concat([df1[["chromosome", "start", "end"]], df2[["chromosome", "start", "end"]]])
all_bins = all_bins.drop_duplicates()
all_bins = all_bins.sort_values(["chromosome", "start", "end"]).reset_index(drop=True)

# Function to compute log2 for each unified bin from an original .cns file
def assign_log2_to_bins(unified_bins, source_df):
    results = []
    for idx, row in unified_bins.iterrows():
        chrom, start, end = row["chromosome"], row["start"], row["end"]
        
        # Find overlapping rows from source_df
        overlaps = source_df[
            (source_df["chromosome"] == chrom) &
            (source_df["start"] < end) &
            (source_df["end"] > start)
        ]
        
        if overlaps.empty:
            results.append(np.nan)
        else:
            # Compute the overlap length with each overlapping segment
            overlaps = overlaps.copy()
            overlaps["overlap"] = overlaps.apply(
                lambda r: max(0, min(r["end"], end) - max(r["start"], start)),
                axis=1
            )
            # Weighted average based on overlap
            weighted_avg = np.average(overlaps["log2"], weights=overlaps["overlap"])
            results.append(weighted_avg)
    return results

# Map log2 values from both files to unified bins
all_bins["log2_1"] = assign_log2_to_bins(all_bins, df1)
all_bins["log2_2"] = assign_log2_to_bins(all_bins, df2)

# Drop rows where both log2 values are missing
all_bins.dropna(subset=["log2_1", "log2_2"], how="all", inplace=True)

# Fill remaining NaNs with 0 (optional: or use another imputation strategy)
all_bins["log2_1"].fillna(0, inplace=True)
all_bins["log2_2"].fillna(0, inplace=True)

# Save aligned vectors
np.savetxt("log2_file1_vector.txt", all_bins["log2_1"].values)
np.savetxt("log2_file2_vector.txt", all_bins["log2_2"].values)

# Compute cosine similarity
vec1 = all_bins["log2_1"].values.reshape(1, -1)
vec2 = all_bins["log2_2"].values.reshape(1, -1)
cos_sim = cosine_similarity(vec1, vec2)[0][0]

print(f"Cosine similarity: {cos_sim:.4f}")
