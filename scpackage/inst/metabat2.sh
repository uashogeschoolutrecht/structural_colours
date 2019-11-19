#!/bin/bash

#activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate metabat2
# Test if active

#############
# user input
#############

# input flag s (path) for single end and p for paired end (path1,path2), output name and main path dir
while getopts b:f:o: aflag
do
case "${aflag}"
in
b) INPUT_S_BAM=${OPTARG};;
f) INPUT_FA=${OPTARG};;
o) OUT_DIR=${OPTARG};;
esac
done

jgi_summarize_bam_contig_depths --outputDepth mapped.depth.txt ${INPUT_S_BAM}

metabat2 -i ${INPUT_FA} \
-a mapped.depth.txt \
-o mapped.metabat -t 10 -m 1500 -v --unbinned

mkdir ${OUTDIR}
mv mapped.* ${OUTDIR}
mv mapped.depth.txt ${OUTDIR}

#grep ">" mapped.metabat.1.fa | sed 's/>//g' > mapped.metabat.1.contigNames

#prokka --proteins scpackage/inst/extdata/'M.6 M.17 IR1.txt' --outdir prokka_test \
#--prefix S1 data/geodescent/samples/MGYS00005036/megahit/SRR6231130/final.contigs.fa
