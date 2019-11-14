#!/bin/bash

/opt/bbmap/bbmap.sh ref=test2.fa \
in=research_drive/geodescent/samples/MGYS00005036/SRR6231130_1.fastq.gz \
in2=research_drive/geodescent/samples/MGYS00005036/SRR6231130_2.fastq.gz \
out=mapped.bam bs=bs.sh; sh bs.sh \
bamscript=outfile3 \
covstats=covstats_test2.txt 

jgi_summarize_bam_contig_depths --outputDepth mapped.depth.txt mapped_sorted.bam

metabat2 -i test2.fa \
-a mapped.depth.txt \
-o mapped.metabat -t 10 -m 1500 -v --unbinned

grep ">" mapped.metabat.1.fa | sed 's/>//g' > mapped.metabat.1.contigNames

prokka --proteins scpackage/inst/extdata/'M.6 M.17 IR1.txt' --outdir prokka_test \
--prefix S1 data/geodescent/samples/MGYS00005036/megahit/SRR6231130/final.contigs.fa