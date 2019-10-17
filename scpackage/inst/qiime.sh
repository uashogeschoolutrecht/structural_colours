#!/bin/bash

# Script to run qiime2-2019.7 on shotgun metagenomes
# Author: Patty Rosendaal
# Date: 11-Oct-2019

###   Preparing data  ###
# Get SRA file
if [ ! -f /home/$USER/research_drive/geodescent/SRR7778149.1 ]; then
    wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778149/SRR7778149.1
    mv SRR7778149.1 /home/$USER/research_drive/geodescent/
fi
# Dumping fastq files
if [ ! -f /home/$USER/research_drive/geodescent/SRR7778149.1_1.fastq ]; then
    echo "Dumping and splitting fastq files:"
    fastq-dump --split-files /home/$USER/research_drive/geodescent/SRR7778149.1
fi

# Specifying samples to use
SAMPLE11="/home/$USER/research_drive/geodescent/SRR7778149.1_1.fastq"
SAMPLE12="/home/$USER/research_drive/geodescent/SRR7778149.1_2.fastq"


###   Activating qiime environment   ###
source /opt/conda/etc/profile.d/conda.sh
conda activate qiime2-2019.7
# Test if activation works
qiime --version


############################################################################
#    Running qiime taxonomy analysis on compost metagenome SRR7778149.1    #
############################################################################

###   Creating manifest en metadata file   ###
touch manifest_SRR7778149.1.txt
echo "#manifest for import SRR7778149 fastq files
sample-id,absolute-filepath,direction
sample_1,$SAMPLE11,forward
sample_1,$SAMPLE12,reverse" > manifest_SRR7778149.1.txt
mv manifest_SRR7778149.1.txt /home/$USER/research_drive/geodescent/

touch sample_1_metadata.txt
echo "#metadata file
SampleID  Year  Latitude  Longtitude  Type  Incubation
sample_1  2018  NA  NA  compost 118" > sample_1_metadata.txt
mv sample_1_metadata.txt /home/$USER/research_drive/geodescent/

###   Importing sequences as qiime objects   ###
if [ ! -f /home/$USER/research_drive/geodescent/sample_1.qza ]; then
    echo "Importing sequences, this might take some time" #1u 15'
    
    qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path /home/$USER/research_drive/geodescent/manifest_SRR7778149.1.txt --output-path /home/$USER/research_drive/geodescent/sample_1.qza --input-format PairedEndFastqManifestPhred33
fi

###   Creating visualization of the sample reads   ###
echo "NOTE: The .qzv file can be visualized in QIIME2 view"

if [ ! -f /home/$USER/research_drive/geodescent/sample_1.qzv ]; then
    qiime demux summarize --i-data /home/$USER/research_drive/geodescent/sample_1.qza --o-visualization /home/$USER/research_drive/geodescent/sample_1.qzv
fi

###   Trimming and denoising   ###
if [ ! -f /home/$USER/research_drive/geodescent/sample_1_rep_seqs.qza ]; then
    echo "Trimming and denoising sequences using dada2, this might take some time"
    
    qiime dada2 denoise-paired --i-demultiplexed-seqs /home/$USER/research_drive/geodescent/sample_1.qza --p-trim-left-f 10 --p-trim-left-r 10 --p-trunc-len-f 120 --p-trunc-len-r 90 --o-table /home/$USER/research_drive/geodescent/sample_1_table.qza --o-representative-sequences /home/$USER/research_drive/geodescent/sample_1_rep_seqs.qza --o-denoising-stats /home/$USER/research_drive/geodescent/sample_1_denoising_stats.qza
fi
#Visualize results
if [ ! -f /home/$USER/research_drive/geodescent/sample_1_denoising_stats.qza ]; then
    echo "Creating visualization of denoising statistics table"
    
    qiime metadata tabulate --m-input-file /home/$USER/research_drive/geodescent/sample_1_denoising_stats.qza --o-visualization /home/$USER/research_drive/geodescent/sample_1_denoising_stats.qzv
fi

#Creating classifier
if [ ! -f /home/$USER/research_drive/geodescent/classifier.qza ]; then
    echo "Creating taxonomy classifier from SILVA 132 99 16S database"
    
    wget https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip
    #UNZIP?
    qiime tools import --type 'FeatureData[Sequence]' --input-path ./SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna --output-path silva132_99
    qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path ./SILVA_132_QIIME_release/taxonomy/16S_only/99/taxonomy_7_levels.txt --output-path silva132_99_ref_taxonomy
    qiime feature-classifier extract-reads --i-sequences silva132_99.qza --p-f-primer GTGCCAGCMGCCCGCGGTAA --p-r-primer GGACTACHVGGGTWTCTAAT --p-trunc-len 300 --o-reads ref_seqs
    qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads ref_seqs.qza --i-reference-taxonomy silva132_99_ref_taxonomy.qza --o-classifier classifier.qza --p-classify--chunk-size 1000
fi

#Classifying sample taxonomy
if [ ! -f /home/$USER/research_drive/geodescent/sample_1_taxa_bar_plots.qzv ]; then
    echo "Classifying taxonomy of sample"
    
    qiime feature-classifier classify-sklearn --i-classifier /home/$USER/research_drive/geodescent/classifier.qza --i-reads /home/$USER/research_drive/geodescent/sample_1_rep_seqs.qza --o-classification /home/$USER/research_drive/geodescent/sample_1_taxonomy.qza
    qiime metadata tabulate --m-input-file /home/$USER/research_drive/geodescent/sample_1_taxonomy.qza --o- /home/$USER/research_drive/geodescent/taxonomy
    qiime taxa barplot --i-table /home/$USER/research_drive/geodescent/sample_1_table.qza --i-taxonomy /home/$USER/research_drive/geodescent/sample_1_taxonomy.qza --m-metadata-file /home/$USER/research_drive/geodescent/sample_1_metadata.txt --o-visualization /home/$USER/research_drive/geodescent/sample_1_taxa_bar_plots
fi
