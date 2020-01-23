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

prefetch ${ACC}
touch ${OUTDIR}/md5.txt
echo "${ACC}\t$(md5sum ~/ncbi/public/sra/${ACC}*).sra" >> ${OUTDIR}/md5.txt
fastq-dump ${LIB} ${ACC}
gzip ${ACC}*
