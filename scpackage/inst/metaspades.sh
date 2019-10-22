#!/bin/bash

# Specifying samples to use
SAMPLE11="/home/$USER/research_drive/geodescent/SRR7778149.1_1.fastq"
SAMPLE12="/home/$USER/research_drive/geodescent/SRR7778149.1_2.fastq"

spades.py -1 $SAMPLE11 -2 $SAMPLE12 --meta -o /home/$USER/research_drive/geodescent/sample_1_spades