#!/bin/bash

# Script to run qiime2-2019.7 analysis pipeline
# Author: Patty Rosendaal
# Date: 11-Oct-2019


#############
# user input
#############

# input flag s (path) for single end and p for paired end (path1,path2), output name and main path dir
while getopts s:p:o:d: aflag
do
case "${aflag}"
in
s) INPUT_SE=${OPTARG};;
p) INPUT_PE=${OPTARG};;
o) OUTPUT_NAME=${OPTARG};;
d) DRIVE_DIR=${OPTARG};;
esac
done
#splitting paired reads file paths
IFS=',' read -r PE_1 PE_2 <<< "$INPUT_PE"

#checking input
if [ ! -z "$INPUT_SE" ]; then
   echo "Supplied single end read $INPUT_SE"
fi
if [ ! -z "$INPUT_PE" ]; then
   echo "Supplied paired end reads $PE_1 and $PE_2"
fi
if [ ! -z "$INPUT_SE" ] && [ ! -z "$INPUT_PE" ]; then
   echo "WARNING: both paired end and single end options used, this is not logical. Please check that your input is one sample."
fi

#creating output dir, checking input
echo "Saving results on research drive $DRIVE_DIR"

if [ -d $DRIVE_DIR/${OUTPUT_NAME} ]; then
    echo "WARNING: output directory $DRIVE_DIR/${OUTPUT_NAME} already exists."
fi

if [ ! -d $DRIVE_DIR/${OUTPUT_NAME} ]; then
    echo "Creating output directory $DRIVE_DIR/${OUTPUT_NAME}"
    
    mkdir $DRIVE_DIR/${OUTPUT_NAME}
fi

###########
# running
###########

###   Activating qiime environment   ###
source /opt/conda/etc/profile.d/conda.sh
conda activate qiime2-2019.7
# Test if activation works
qiime --version

###   Creating manifest en metadata file   ###
#PE
if [ ! -z "$INPUT_PE" ]; then
    if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/metadata_${OUTPUT_NAME}.txt ]; then
        touch manifest_${OUTPUT_NAME}.txt
        echo "#manifest for import PE fastq files
sample-id,absolute-filepath,direction
${OUTPUT_NAME},$PE_1,forward
${OUTPUT_NAME},$PE_2,reverse" > manifest_${OUTPUT_NAME}.txt
        mv manifest_${OUTPUT_NAME}.txt $DRIVE_DIR/${OUTPUT_NAME}/

        touch metadata_${OUTPUT_NAME}.txt
        echo "#metadata file
sample-id  Type
${OUTPUT_NAME}  metagenome" > metadata_${OUTPUT_NAME}.txt
        mv metadata_${OUTPUT_NAME}.txt $DRIVE_DIR/${OUTPUT_NAME}/
    fi
fi

#SE
if [ ! -z "$INPUT_SE" ]; then
    if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/metadata_${OUTPUT_NAME}.txt ]; then
        touch manifest_${OUTPUT_NAME}.txt
        echo "#manifest for import SE fastq file
sample-id,absolute-filepath
${OUTPUT_NAME},$INPUT_SE" > manifest_${OUTPUT_NAME}.txt
        mv manifest_${OUTPUT_NAME}.txt $DRIVE_DIR/${OUTPUT_NAME}/

        touch metadata_${OUTPUT_NAME}.txt
        echo "#metadata file
sample-id  Type
${OUTPUT_NAME}  metagenome" > metadata_${OUTPUT_NAME}.txt
        mv metadata_${OUTPUT_NAME}.txt $DRIVE_DIR/${OUTPUT_NAME}/
    fi
fi

###   Importing sequences as qiime objects   ###
if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qza ] && [ ! -z "$INPUT_SE" ]; then
    echo "Importing single end sequence, this might take some time" #1u 15'
    
    qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path $DRIVE_DIR/${OUTPUT_NAME}/manifest_${OUTPUT_NAME}.txt --output-path $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qza --input-format FastqManifestPhred33
fi
if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qza ] && [ ! -z "$INPUT_PE" ]; then
    echo "Importing paired end sequences, this might take some time" #1u 15'
    
    qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path $DRIVE_DIR/${OUTPUT_NAME}/manifest_${OUTPUT_NAME}.txt --output-path $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qza --input-format PairedEndFastqManifestPhred33
fi

###   Creating visualization of the sample reads   ###
echo "NOTE: The .qzv file can be visualized in QIIME2 view"

if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qzv ]; then
    qiime demux summarize --i-data $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qza --o-visualization $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qzv
fi



###   Trimming and denoising   ###
if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_rep_seqs.qza ]; then
    echo "Trimming and denoising sequences using dada2, this might take some time"
    
    R --version
    qiime dada2 denoise-paired --verbose --p-n-threads 4 --i-demultiplexed-seqs $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}.qza --p-trim-left-f 75 --p-trim-left-r 75 --p-trunc-len-f 825 --p-trunc-len-r 825 --o-table $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_table.qza --o-representative-sequences $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_rep_seqs.qza --o-denoising-stats $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_denoising_stats.qza
fi
#Visualize results
if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_denoising_stats.qza ]; then
    echo "Creating visualization of denoising statistics table"
    
    qiime metadata tabulate --m-input-file $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_denoising_stats.qza --o-visualization $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_denoising_stats.qzv
fi

#Creating classifier
if [ ! -f $DRIVE_DIR/classifier.qza ]; then
    echo "Creating taxonomy classifier from SILVA 132 99 16S database"
    
    wget https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip
    #UNZIP?
    qiime tools import --type 'FeatureData[Sequence]' --input-path ./SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna --output-path silva132_99
    qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path ./SILVA_132_QIIME_release/taxonomy/16S_only/99/taxonomy_7_levels.txt --output-path silva132_99_ref_taxonomy
    qiime feature-classifier extract-reads --i-sequences silva132_99.qza --p-f-primer GTGCCAGCMGCCCGCGGTAA --p-r-primer GGACTACHVGGGTWTCTAAT --p-trunc-len 300 --o-reads ref_seqs
    qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads ref_seqs.qza --i-reference-taxonomy silva132_99_ref_taxonomy.qza --o-classifier classifier.qza --p-classify--chunk-size 1000
fi

#Classifying sample taxonomy
if [ ! -f $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_taxa_bar_plots.qzv ]; then
    echo "Classifying taxonomy of sample"
    
    qiime feature-classifier classify-sklearn --i-classifier $DRIVE_DIR/classifier.qza --i-reads $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_rep_seqs.qza --o-classification $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_taxonomy.qza
    qiime metadata tabulate --m-input-file $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_taxonomy.qza --o- $DRIVE_DIR/${OUTPUT_NAME}/taxonomy
    qiime taxa barplot --i-table $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_table.qza --i-taxonomy $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_taxonomy.qza --m-metadata-file /$DRIVE_DIR/${OUTPUT_NAME}/metadata_${OUTPUT_NAME}.txt --o-visualization $DRIVE_DIR/${OUTPUT_NAME}/${OUTPUT_NAME}_taxa_bar_plots
fi
