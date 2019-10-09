#!/bin/bash

# get SRA file for compost metagenome with M17 hit
wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778149/SRR7778149.1

# move to inst/extdata
mv SRR7778149.1 ../inst/extdata/

