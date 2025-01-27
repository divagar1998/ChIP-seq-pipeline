from pyliftover import LiftOver
import argparse
import csv

def read_cns_file(file_path):
    chromosome, start, end, probes, log2, gene = [],[],[],[],[],[]
    with open(file_path, 'r') as file:
        reader = csv.reader(file, delimiter='\t')

        header = next(reader)

        for row in reader:
            chromosome += [row[0]]
            start += [row[1]]
            end += [row[2]]
            probes += [row[3]]
            log2 += [row[4]]
            gene += [row[5]]

    return header, chromosome, start, end, probes, log2, gene

def write_cns_file(header, chromosome, new_start, new_end, probes, log2, gene, output_file):
    with open(output_file, 'w', newline='') as file:
            writer = csv.writer(file, delimiter='\t')
            writer.writerow(header)
            for i in range(0, len(chromosome)):
                row = [chromosome[i], new_start[i], new_end[i], probes[i], log2[i], gene[i]]
                writer.writerow(row)
    return None

def main():
    parser = argparse.ArgumentParser()
    # Add arguments
    parser.add_argument("-f", "--file", required=True, help="Input .cns file to liftover")
    parser.add_argument("-o", "--output", required=True)
    # Parse the arguments
    args = parser.parse_args()

    lo = LiftOver('hg19', 'hg38')
    header, chromosome, start, end, probes, log2, gene = read_cns_file(args.file)
    
    new_start, new_end = [],[]
    for i in range(0,len(chromosome)):
        try:
            new_start += [str(round(lo.convert_coordinate(chromosome[i], float(start[i]))[0][1]))]
        #IndexError occurs when liftover outputs None
        except IndexError:
            new_start += ["REMOVE"]
        try:
            new_end += [str(round(lo.convert_coordinate(chromosome[i], float(end[i]))[0][1]))]
        except IndexError:
            new_end += ["REMOVE"]
    
    remove_indices = []
    for i in range(0, len(new_start)):
        if new_start[i] == "REMOVE" or new_end[i] == "REMOVE":
            remove_indices += [i]
    for i in range(0, len(remove_indices)):
        chromosome.pop(remove_indices[i]-i)
        new_start.pop(remove_indices[i]-i)
        new_end.pop(remove_indices[i]-i)
        probes.pop(remove_indices[i]-i)
        log2.pop(remove_indices[i]-i)
        gene.pop(remove_indices[i]-i)

    write_cns_file(header, chromosome, new_start, new_end, probes, log2, gene, args.output)

if __name__ == "__main__":
    main()


