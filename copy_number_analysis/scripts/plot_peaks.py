import argparse
import matplotlib.pyplot as plt

def read_bed_file(bed_file):
    """Reads a BED file and returns a list of [chromosome, start, end, CNV, read_count, label]."""
    bed_matrix = []
    with open(bed_file, 'r') as f:
        for line in f:
            columns = line.strip().split("\t")
            if len(columns) >= 6:
                chrom, start, end, cnv, read_count, input_reads, ratio, label = columns[0], int(columns[1]), int(columns[2]), float(columns[3]), int(columns[4]),int(columns[5]),float(columns[6]), columns[7]
                bed_matrix.append([chrom, start, end, cnv, read_count, input_reads, ratio,label])
    return bed_matrix

def plot_scatter(bed_matrix, output_file):
    """Plots a scatter plot of CNV vs read count for intervals with 'have_peak' and 'no_peak' labels."""
    # Separate intervals into have_peak and no_peak based on the label
    have_peak = [row for row in bed_matrix if row[7] == 'have_peak']
    no_peak = [row for row in bed_matrix if row[7] == 'no_peak']

    # Extract CNV and read count for each group
    cnv_have_peak = [row[3] for row in have_peak]
    read_ratio_have_peak = [row[6] for row in have_peak]
    
    cnv_no_peak = [row[3] for row in no_peak]
    read_ratio_no_peak = [row[6] for row in no_peak]

    # Create the scatter plot
    plt.figure(figsize=(10, 8))

    # Plot for 'have_peak'
    plt.scatter(cnv_have_peak, read_ratio_have_peak, color='blue', alpha=0.5, label='Have Peak')

    # Plot for 'no_peak'
    plt.scatter(cnv_no_peak, read_ratio_no_peak, color='red', alpha=0.5, label='No Peak')

    # Add labels and title
    plt.xlabel('Copy Number Variation (CNV)')
    plt.ylabel('Read Ratio')
    plt.title('Scatter Plot of CNV vs Read Count')

    # Add a legend to differentiate the groups
    plt.legend()

    # Add a grid for better readability
    plt.grid(True)

    # Save the plot as an image
    plt.savefig(output_file, format='png')
    


def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Plot CNV vs Read Count for intervals with 'have_peak' and 'no_peak' labels.")
    parser.add_argument("bed_file", type=str, help="Path to the BED file with CNV, read count, and peak labels")
    parser.add_argument("output_file", type=str, help="Output file path to save the scatter plot (e.g., 'scatter_plot.png')")
    
    args = parser.parse_args()

    # Read the BED file
    bed_matrix = read_bed_file(args.bed_file)

    # Plot the scatter plot of CNV vs read count
    plot_scatter(bed_matrix, args.output_file)

if __name__ == "__main__":
    main()