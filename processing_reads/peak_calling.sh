#! /bin/bash


ml macs/2.1.0

macs2 callpeak -t "/hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H1048/SRR24312433.woblacklist.sorted.rmdup.bam" \
-c "/hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H1048/SRR11826627.woblacklist.sorted.rmdup.bam" \
-g hs -n "H1048_chip_peaks" -f BAM -B --keep-dup 'all'
