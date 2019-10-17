#!/bin/bash

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


###   Installation   ###
if [ ! -d SPAdes-3.12.0-Linux ]; then
    wget http://cab.spbu.ru/files/release3.12.0/SPAdes-3.12.0-Linux.tar.gz
    tar -xzf SPAdes-3.12.0-Linux.tar.gz
    echo "export PATH=$PWD/SPAdes-3.12.0-Linux/bin:$PATH" >> ~/.bashrc
fi

source ~/.bashrc

spades.py -1 $SAMPLE11 -2 $SAMPLE12 --meta -o sample_1_spades