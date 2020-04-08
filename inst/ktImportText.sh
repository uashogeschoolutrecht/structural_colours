#!/bin/bash

#activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate krona

#user input
while getopts i:o: aflag
do
case "${aflag}"
in
i) INFILES=${OPTARG};;
o) OUTFILE=${OPTARG};;
esac
done

ktImportText -o ${OUTFILE} ${INFILES}
