#!/bin/bash

source /opt/conda/etc/profile.d/conda.sh
conda activate sratoolkit

while getopts a:o:l: aflag
do
case "${aflag}"
in
a) ACC=${OPTARG};;
o) OUTDIR=${OPTARG};;
l) LIB=${OPTARG};;
esac
done

prefetch --max-size 100G ${ACC}
vdb-validate ${ACC}
fastq-dump ${LIB} ${ACC}
gzip ${ACC}*
