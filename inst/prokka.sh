#!/bin/bash

# Author: Patty Rosendaal
# Date: 18-12-2019
# Script to activate and run prokka annotation pipeline

#activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate prokka
# Test if active
prokka --version

#user input
while getopts c:o:p: aflag
do
case "${aflag}"
in
c) INPUT_CONTIGS=${OPTARG};;
o) OUTDIR=${OPTARG};;
p) PREFIX=${OPTARG};;
esac
done

#run prokka
prokka --metagenome --cpus 0 --gffver 2 --prefix ${PREFIX} --outdir ${OUTDIR} ${INPUT_CONTIGS}