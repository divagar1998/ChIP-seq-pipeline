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
                if len(columns) >= 5:
                    chrom, start, end, cnv, count = columns[0], int(columns[1]), int(columns[2]), float(columns[3]),int(columns[4])
                    bed_matrix.append([chrom, start, end,cnv, count])
    return bed_matrix

def calculate_chip_input_ratio(chip_bed_matrix, input_bed_matrix):
    l = len(chip_bed_matrix)
    L = len(input_bed_matrix)
    for i in range(l):
        if (chip_bed_matrix[i][0] == input_bed_matrix[i][0]) and (chip_bed_matrix[i][1] == input_bed_matrix[i][1]) and (chip_bed_matrix[i][2] == input_bed_matrix[i][2]):
            if input_bed_matrix[i][4] == 0:
                chip_bed_matrix[i] += [input_bed_matrix[i][4], round(chip_bed_matrix[i][4]/1,2)]
            else:
                chip_bed_matrix[i] += [input_bed_matrix[i][4], round(chip_bed_matrix[i][4]/input_bed_matrix[i][4],2)] 
    return chip_bed_matrix

def save_matrix(output_matrix,output_bed_file):
    with open(output_bed_file, 'w') as f:
        for row in output_matrix:
            f.write(f"{row[0]}\t{row[1]}\t{row[2]}\t{row[3]}\t{row[4]}\t{row[5]}\t{row[6]}\n")

def main():
    parser = argparse.ArgumentParser(description="Read and process BED and .cnr files.")
    parser.add_argument("chip_bed_file", type=str, help="Path to the BED file")
    parser.add_argument("input_bed_file", type=str, help="Path to the .cnr file")
    
    args = parser.parse_args()

    # Read the BED and .cnr files into matrices
    chip_bed_matrix = read_bed_file(args.chip_bed_file)
    input_bed_matrix = read_bed_file(args.input_bed_file)
    output_matrix = calculate_chip_input_ratio(chip_bed_matrix,input_bed_matrix)
    save_matrix(output_matrix, "MDA-MB-231_ratio_matrix.bed")


if __name__ == "__main__":
    main()