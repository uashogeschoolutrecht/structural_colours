#!/bin/bash
#########
# NeSSM
#########

# get NCBI genomes (7.8 Gb)
if [ ! -d /home/$USER/research_drive/geodescent/NeSSM ]; then
    mkdir /home/$USER/research_drive/geodescent/NeSSM
    mkdir /home/$USER/research_drive/geodescent/NeSSM/NCBI
    perl /NeSSM/scripts/complete_update_step.pl /home/$USER/research_drive/geodescent/NeSSM/NCBI
fi

# create index file from NCBI genomes
if [ ! -d /home/$USER/research_drive/geodescent/NeSSM_index ]; then
    mkdir /home/$USER/research_drive/geodescent/NeSSM/NeSSM_index
    perl /NeSSM/scripts/mk_index.pl /home/$USER/research_drive/geodescent/NeSSM/NCBI /home/$USER/research_drive/geodescent/NeSSM/NeSSM_index
fi

#