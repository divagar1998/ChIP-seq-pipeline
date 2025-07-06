import sys

def normalize_bedgraph(input_file, output_file, target_sum=1_000_000):
    rows = []

    with open(input_file, 'r') as f:
        for line in f:
            if line.strip() == "" or line.startswith(("#", "track", "browser")):
                continue  
            parts = line.strip().split()
            if len(parts) < 4:
                continue  
            chrom, start, end, value = parts[0], int(parts[1]), int(parts[2]), float(parts[3])
            rows.append((chrom, start, end, value))

    # Calculate total sum of the 4th column
    total = sum([r[3] for r in rows])
    if total == 0:
        print("Total sum of the 4th column is 0. Cannot normalize.")
        sys.exit(1)

    # Compute scaling factor
    scaling_factor = target_sum / total
    print(f"Total before normalization: {total}")
    print(f"Scaling factor: {scaling_factor}")

    # Write the normalized output
    with open(output_file, 'w') as f:
        for chrom, start, end, value in rows:
            norm_value = value * scaling_factor
            f.write(f"{chrom}\t{start}\t{end}\t{norm_value:.6f}\n")

    print(f"Normalization complete. Output written to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python normalize_bdg.py <input.bdg> <output.bdg>")
        sys.exit(1)

    input_bdg = sys.argv[1]
    output_bdg = sys.argv[2]
    normalize_bedgraph(input_bdg, output_bdg)
