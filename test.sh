#! /bin/bash

set -euo pipefail

if [ -e ./22RV1/SRR18609888_1.fastq ] && [ -e ./22RV1/SRR18609888_3.fastq ]
then echo "ok"
else echo "not ok"
fi