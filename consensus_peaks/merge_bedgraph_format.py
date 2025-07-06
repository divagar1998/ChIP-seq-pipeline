import pandas as pd

# code to merge bedgraph files from multiple samples
# and normalize the pileup values by dividing by 3

file_path = "SCLC_N_cMYC_pileup_shared_peaks.bdg"
output_file = "SCLC_N_cMYC_pileup_split_merged_normalized.bdg"

df = pd.read_csv(file_path, sep='\t', header=None, names=['chrom', 'start', 'end', 'pileup'])
df = df.sort_values(by=['chrom', 'start'])

merged_intervals = []

prev_chrom = None
prev_start = None
prev_end = None
prev_pileup = 0.0

for index, row in df.iterrows():
    chrom, start, end, pileup = row['chrom'], row['start'], row['end'], row['pileup']

    if chrom != prev_chrom or start >= prev_end:
        if prev_chrom is not None:
            merged_intervals.append([prev_chrom, prev_start, prev_end, prev_pileup / 3])

        prev_chrom = chrom
        prev_start = start
        prev_end = end
        prev_pileup = float(pileup)
    else:
        if start < prev_end:
            prev_end = max(prev_end, end)
            prev_pileup += float(pileup)
        if end > prev_end:
            merged_intervals.append([chrom, prev_end, end, float(pileup) / 3]) 

with open(output_file, 'w') as f:
    for interval in merged_intervals:
        f.write('\t'.join(map(str, interval)) + '\n')

print(f"Merged intervals written to {output_file}")
