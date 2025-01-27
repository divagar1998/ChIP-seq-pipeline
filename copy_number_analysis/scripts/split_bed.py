import sys
import argparse

def read_bed_file(input_file):

    bed_data = []
    
    with open(input_file, 'r') as f:
        for line in f:
            # strip() removes spaces, tabs and newline
            if not line.strip() or line.startswith('#'):
                continue
            # Parse the line into chromosome, start, and end
            chr_name, start, end = line.strip().split()[:3]
            bed_data.append([chr_name, int(start), int(end)])
    
    return bed_data

def split_bed_by_1mb(bed_data):
    l = len(bed_data)
    i = 0
    while i < l:
        chr = bed_data[i][0]
        start = bed_data[i][1]
        end = bed_data[i][2]
        if start + 1000000 < end:
            bed_data = bed_data[:i] + [[chr,start, start+1000000]] + [[chr,start+1000001,end]] + bed_data[i+1:]
            i += 1
            l += 1
        else: 
            i += 1
    return bed_data

def write_bed_file(output_file, bed_data):
    # Writes the BED data (matrix) to a file with tab-separated values.
    
    with open(output_file, 'w') as f:
        for entry in bed_data:
            f.write(f"{entry[0]}\t{entry[1]}\t{entry[2]}\n")

def main():
    parser = argparse.ArgumentParser(description="Split a BED file into 1MB chunks and write it back to a new file.")
    
    # Define command-line arguments
    parser.add_argument('input_file', type=str, help="Input BED file to process.")
    parser.add_argument('output_file', type=str, help="Output BED file to save the split data.")
    args = parser.parse_args()

    # Read the BED file into a matrix
    bed_data = read_bed_file(args.input_file)

    # Split the BED data by 1MB genomic regions
    split_data = split_bed_by_1mb(bed_data)

    # Write the processed data back to a new BED file
    write_bed_file(args.output_file, split_data)

if __name__ == "__main__":
    main()


