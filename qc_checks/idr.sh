#! /bin/bash

# load idr-env using conda or use the modules listed below
# ml idr/2.0.3
# ml gcc/14.2.0
# ml python/3.7.3


cd /hpc/users/divagt01/watanabe/Divagar/ChIP_seq_files/H2171/peak_calling_idr
idr --samples  H2171_br2_sorted.narrowPeak H2171_br3_sorted.narrowPeak \
    --input-file-type narrowPeak \
    --rank p.value \
    --output-file H2171-br2-br3 \
    --plot \
    --log-output-file H2171-br2-br3.idr.log

