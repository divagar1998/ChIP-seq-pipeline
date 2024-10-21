import subprocess

# Define the command and its arguments
command = [
    "bamPEFragmentSize",
    "-b", "/hpc/users/divagt01/watanabe/Divagar/cmyc_chipseq_analysis/cmyc_cell_lines/H2171/H2171_cmyc_chip_woblacklist.sorted.rmdup.bam",  # Path to your input BAM file
    "-o", "hist.png",  # Path for output BigWig file
]

# Run the command
try:
    subprocess.run(command, check=True)
    print("Command executed successfully.")
except subprocess.CalledProcessError as e:
    print(f"An error occurred: {e}")




