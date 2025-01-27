import argparse

def read_bed_file(bed_file):
    """Reads a BED file and returns a list of [chromosome, start, end, label]."""
    bed_matrix = []
    with open(bed_file, 'r') as f:
        for line in f:
            columns = line.strip().split("\t")
            if len(columns) >= 5:
                chrom, start, end, cnv, reads, input_reads, ratio = columns[0], int(columns[1]), int(columns[2]), float(columns[3]), int(columns[4]),int(columns[5]), float(columns[6])
                bed_matrix+=[[chrom, start, end, cnv, reads, input_reads, ratio,'no_peak']]
    return bed_matrix

def read_narrowpeak_file(narrowpeak_file):
    """Reads a NarrowPeak file and returns a list of [chromosome, start, end]."""
    peak_matrix = []
    with open(narrowpeak_file, 'r') as f:
        for line in f:
            columns = line.strip().split("\t")
            if len(columns) >= 3:
                chrom, start, end = columns[0], int(columns[1]), int(columns[2])
                peak_matrix.append([chrom, start, end])
    return peak_matrix

def check_overlap(bed_interval, peak_intervals):
    """Checks if the BED interval overlaps with any of the NarrowPeak intervals."""
    bed_chrom, bed_start, bed_end = bed_interval[:3]
    for peak in peak_intervals:
        peak_chrom, peak_start, peak_end = peak
        if bed_chrom == peak_chrom and not (bed_end <= peak_start or bed_start >= peak_end):
            return True
    return False

def label_bed_intervals(bed_matrix, peak_matrix):
    """Labels each BED interval as 'have_peak' or 'no_peak' based on overlap with peaks."""
    for bed_interval in bed_matrix:
        print(bed_interval)
        if check_overlap(bed_interval, peak_matrix):
            bed_interval[7] = 'have_peak'
    return bed_matrix

def save_bed_with_labels(bed_matrix, output_bed_file):
    """Saves the updated BED matrix (with labels) to a new BED file."""
    with open(output_bed_file, 'w') as f:
        for row in bed_matrix:
            f.write("\t".join(map(str, row)) + "\n")

def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Label BED intervals based on overlap with NarrowPeak file.")
    parser.add_argument("bed_file", type=str, help="Path to the BED file")
    parser.add_argument("narrowpeak_file", type=str, help="Path to the NarrowPeak file")
    parser.add_argument("output_bed_file", type=str, help="Output BED file path to save the labeled intervals")

    args = parser.parse_args()

    # Read the BED and NarrowPeak files
    bed_matrix = read_bed_file(args.bed_file)
    peak_matrix = read_narrowpeak_file(args.narrowpeak_file)

    # Label the BED intervals based on overlap with the peaks
    labeled_bed_matrix = label_bed_intervals(bed_matrix, peak_matrix)

    # Save the updated BED file with the labels
    save_bed_with_labels(labeled_bed_matrix, args.output_bed_file)

if __name__ == "__main__":
    main()