#!/bin/bash

# Script to run metaphlan2
# Author: Patty Rosendaal
# Date: 2-Dec-2019

###   Activating metaphlan environment   ###
source /opt/conda/etc/profile.d/conda.sh
conda activate q2-metaphlan2
# Test if activation works
metaphlan2.py -v

#User input
while getopts i:d:b:o: aflag
do
case "${aflag}"
in
i) SAMPLE=${OPTARG};;
d) BOWTIE_DB=${OPTARG};;
b) BOWTIE_OUT=${OPTARG};;
o) OUT_FILE=${OPTARG};;
esac
done

#Run
metaphlan2.py ${SAMPLE} --input_type multifasta --bowtie2out ${BOWTIE_OUT} --bowtie2db ${BOWTIE_DB} --no_map > "${OUT_FILE}"
