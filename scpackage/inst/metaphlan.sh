#!/bin/bash

# Script to run metphlan2
# Author: Patty Rosendaal
# Date: 15-Oct-2019

###   Preparing data  ###
# Get SRA file
if [ ! -f ./SRR7778149.1 ]; then
    wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778149/SRR7778149.1
fi
# Dumping fastq files
if [ ! -f ./SRR7778149.1_1.fastq ]; then
    echo "Dumping and splitting fastq files in working directory:"
    fastq-dump --split-files SRR7778149.1
fi
# Specifying samples to use
SAMPLE11="/home/patty_rosendaal/compost_genome/SRR7778149.1_1.fastq"
SAMPLE12="/home/patty_rosendaal/compost_genome/SRR7778149.1_2.fastq"


###   Activating metaphlan environment   ###
source ~/anaconda3/etc/profile.d/conda.sh
conda activate q2-metaphlan2
# Test if activation works
metaphlan2.py -v

#Run
metaphlan2.py $SAMPLE11,$SAMPLE12 --input_type fastq --biom sample_1_biom_output --bowtie2out sample_1.bowtie2.bz2 > sample_1_metaphlan