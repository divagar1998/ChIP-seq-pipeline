plotFingerprint \
    -b ~/watanabe/Divagar/ChIP_seq_files/H209_LMYC/H209_lmyc_chip_BR2.woblacklist.sorted.rmdup.bam \
    ~/watanabe/Divagar/ChIP_seq_files/H209_LMYC/H209_lmyc_chip_BR3.woblacklist.sorted.rmdup.bam \
    ~/watanabe/Divagar/ChIP_seq_files/H209_H3K27me3/H209_H3K27me3_chip_BR3.woblacklist.sorted.rmdup.bam \
    ~/watanabe/Divagar/ChIP_seq_files/H209_H3K4me3/H209_H3K4me3_chip_BR2.woblacklist.sorted.rmdup.bam \
    ~/watanabe/Divagar/ChIP_seq_files/H209_H3K4me3/H209_H3K4me3_chip_BR3.woblacklist.sorted.rmdup.bam \
    ~/watanabe/Divagar/ChIP_seq_files/H209_LMYC/H209_input.woblacklist.sorted.rmdup.bam \
    --extendReads \
    --labels H209_LMYC_chip_1 H209_LMYC_chip_2 H209_H3K27me3_chip_1 H209_H3K4me3_chip_1 H209_H3K4me3_chip_2 H209_input \
    -p 10 \
    -plot H209_fingerprint.png