import numpy as np
import argparse
import matplotlib.pyplot as plt

def read_bed_file(bed_file):

    bed_matrix = []
    with open(bed_file, 'r') as f:
        for line in f:
            if not line.startswith("#"):  # Skip header lines
                columns = line.strip().split("\t")
                # Ensure we have at least 3 columns (chromosome, start, end)
                if len(columns) >= 4:
                    chrom, start, end, count = columns[0], int(columns[1]), int(columns[2]), int(columns[3])
                    bed_matrix.append([chrom, start, end,count])
    return bed_matrix

def read_cnr_file(cnr_file):
    """
    Reads a .cnr file and returns the data as a list of lists (matrix).
    Each list will represent one row:
    [chromosome, start, end, gene, depth, log2, weight]
    """
    cnr_matrix = []
    with open(cnr_file, 'r') as f:
        # Skip header lines, if any (we assume the first line is a header)
        for line in f:
            # Skip empty lines or lines starting with '#' (comment lines)
            if line.startswith("#") or not line.strip():
                continue
            
            columns = line.strip().split("\t")
            
            # Ensure the line has at least 7 columns: [chromosome, start, end, gene, depth, log2, weight]
            if len(columns) >= 7:
                try:
                    chrom = columns[0]
                    start = int(columns[1])  # Ensure 'start' is an integer
                    end = int(columns[2])    # Ensure 'end' is an integer
                    gene = columns[3]        # 'gene' is a string
                    depth = float(columns[4])  # 'depth' is a float
                    log2 = float(columns[5])  # 'log2' is a float
                    weight = float(columns[6])  # 'weight' is a float

                    cnr_matrix.append([chrom, start, end, gene, depth, log2, weight])

                except ValueError as e:
                    # Catch any value errors and print a message to help with debugging
                    print(f"Skipping invalid line in .cnr file: {line.strip()}")
                    print(f"Error: {e}")

    return cnr_matrix

def calculate_intersect(bed_matrix,cnr_matrix):
    l = len(cnr_matrix)
    L = len(bed_matrix)
    i = 0
    j = 0
    output_matrix = []
    while i < l:
        print(i,j,l,L)
        while j < L:
            if bed_matrix[j][0] > cnr_matrix[i][0]:
                i += 1
                break
            if bed_matrix[j][1] >= cnr_matrix[i][1] and bed_matrix[j][2] <= cnr_matrix[i][2]:
                output_matrix += [[bed_matrix[j][0],bed_matrix[j][1],bed_matrix[j][2],bed_matrix[j][3]]]
                j += 1
            elif bed_matrix[j][1] >= cnr_matrix[i][1] and bed_matrix[j][2] >= cnr_matrix[i][2]:
                if bed_matrix[j][1] <= cnr_matrix[i][2]:
                    output_matrix += [[bed_matrix[j][0],bed_matrix[j][1],bed_matrix[j][2],bed_matrix[j][3]]]
                    j += 1
                else:
                    i += 1
                    break
            else:
                j += 1
    return output_matrix

def calculate_readcounts(intersect_matrix,cnr_matrix):
    output_matrix = []
    null_matrix = []
    l = len(intersect_matrix)
    L = len(cnr_matrix)
    i = 0
    j = 0
    while j < L-1 and i < l-1:
        while i < l:
            if intersect_matrix[i][0] > cnr_matrix[j][0]:
                j += 1
                break
            if intersect_matrix[i][1] >= cnr_matrix[j][1] and intersect_matrix[i][2] <= cnr_matrix[j][2]:
                output_matrix += [[cnr_matrix[j][0],cnr_matrix[j][1],cnr_matrix[j][2],cnr_matrix[j][5],intersect_matrix[i][3]]]
                i += 1
            elif intersect_matrix[i][1] >= cnr_matrix[j][1] and intersect_matrix[i][2] >= cnr_matrix[j][2]:
                if intersect_matrix[i][1] >= cnr_matrix[j][2]:
                    j += 1
                    break
                else:
                    i += 1
            else:
                i += 1
    return output_matrix

def plot_scatter(matrix, output_file):
    filtered_matrix = [row for row in matrix if row[4] > 100]

    """Create a scatter plot of read count (index 4) over copy number (index 5) and save the plot."""
    # Extract copy numbers (log2) and read counts from the matrix
    copy_number = [row[3] for row in filtered_matrix]  # log2 copy number is in index 5
    read_count = [row[4] for row in filtered_matrix]  # read count is in index 4

    # Create the scatter plot
    plt.figure(figsize=(8, 6))
    plt.scatter(copy_number, read_count, color='blue', alpha=0.5)

    # Add labels and title
    plt.xlabel('Copy Number (Log2)')
    plt.ylabel('Read Count')
    plt.title('Scatter Plot of Read Count vs Copy Number')

    # Save the plot as an image
    plt.grid(True)
    plt.savefig(output_file, format='png')  # Save as PNG image

def save_matrix(output_matrix,output_bed_file):
    with open(output_bed_file, 'w') as f:
        for row in output_matrix:
            f.write(f"{row[0]}\t{row[1]}\t{row[2]}\t{row[3]}\t{row[4]}\n")

def main():
    parser = argparse.ArgumentParser(description="Read and process BED and .cnr files.")
    parser.add_argument("bed_file", type=str, help="Path to the BED file")
    parser.add_argument("cnr_file", type=str, help="Path to the .cnr file")
    
    args = parser.parse_args()

    # Read the BED and .cnr files into matrices
    bed_matrix = read_bed_file(args.bed_file)
    cnr_matrix = read_cnr_file(args.cnr_file)
    intersect_matrix = calculate_intersect(bed_matrix,cnr_matrix)
    print("done")
    output_matrix = calculate_readcounts(intersect_matrix,cnr_matrix)
    print("done")
    save_matrix(output_matrix, "MDA-MB-231_input_matrix.bed")
    #plot_scatter(output_matrix,"fig3.png")
    return bed_matrix, cnr_matrix

if __name__ == "__main__":
    main()