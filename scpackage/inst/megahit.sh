#!/bin/bash

# Script to run megahit
# Author: Patty Rosendaal
# Date: 16-Oct-2019


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

# Test if active
megahit -v


###   Run megahit   ###
megahit -1 $SAMPLE11 -2 $SAMPLE12 -o sample_1_megahit