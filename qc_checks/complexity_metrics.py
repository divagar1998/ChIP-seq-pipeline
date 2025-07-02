import pysam
import pandas as pd
from collections import Counter
import os

def count_mapped_reads(bam_path):
    with pysam.AlignmentFile(bam_path, "rb") as bam:
        try:
            #bam.fetch() iterates through the reads in the BAM file
            return sum(1 for read in bam.fetch() if not read.is_unmapped and not read.is_duplicate)
        except ValueError:
            # If the BAM file is not indexed, index it first
            pysam.index(bam_path)
            return sum(1 for read in bam.fetch() if not read.is_unmapped and not read.is_duplicate)


def compute_pbc_metrics(bam_path):
    positions = []

    with pysam.AlignmentFile(bam_path, "rb") as bam:
        for read in bam.fetch():
            if read.is_unmapped or read.is_duplicate:
                continue
            chrom = bam.get_reference_name(read.reference_id)
            strand = '-' if read.is_reverse else '+'
            pos = read.reference_start if strand == '+' else read.reference_end
            positions.append((chrom, strand, pos))

    counts = Counter(positions)
    values = list(counts.values())

    N1 = values.count(1)
    N2 = values.count(2)
    Nd = len(values)

    PBC1 = N1 / Nd if Nd > 0 else 0
    PBC2 = N1 / N2 if N2 > 0 else 0

    return PBC1, PBC2

def process_bam_pairs(csv_path, output_path):
    df = pd.read_csv(csv_path, header=None, names=["unfiltered", "filtered"])
    results = []

    for _, row in df.iterrows():
        unfiltered_bam = row["unfiltered"]
        filtered_bam = row["filtered"]
        sample_name = os.path.basename(unfiltered_bam).replace(".bam", "")

        # Count reads
        unfiltered_reads = count_mapped_reads(unfiltered_bam)
        filtered_reads = count_mapped_reads(filtered_bam)

        # Calculate NRF (filtered / unfiltered)
        NRF = filtered_reads / unfiltered_reads if unfiltered_reads > 0 else 0

        # Compute PBC metrics (from filtered BAM only)
        PBC1, PBC2 = compute_pbc_metrics(filtered_bam)

        results.append([
            sample_name,
            unfiltered_reads,
            filtered_reads,
            round(NRF, 4),
            round(PBC1, 4),
            round(PBC2, 4)
        ])

    out_df = pd.DataFrame(
        results,
        columns=["Sample", "Unfiltered_Reads", "Filtered_Reads", "NRF", "PBC1", "PBC2"]
    )
    out_df.to_csv(output_path, sep="\t", index=False)

process_bam_pairs("~/watanabe/Divagar/ChIP_seq_files/complexity_metrics.csv", "complexity_metrics.txt")
