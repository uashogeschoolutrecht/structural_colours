#!/bin/bash

# Script to run megahit
# Author: Patty Rosendaal
# Date: 16-Oct-2019

#activate environment
source ~/anaconda3/etc/profile.d/conda.sh
conda activate megahit
# Test if active
megahit -v

if [ ! -d /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit ]; then
    mkdir /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit
fi

for i in ERR{833272..833285}; do
mkdir /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit/$i

megahit -1 /home/$USER/research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_forward_unpaired.fq.gz \
-2 /home/$USER/research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_reverse_unpaired.fq.gz \
--out-dir /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit/$i

megahit -r research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_out.fq.gz \
--out-dir /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit/$i
done
