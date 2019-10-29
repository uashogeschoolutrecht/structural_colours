#!/usr/bin/env bash

RESEARCH_DRIVE="/home/$USER/research_drive/geodescent/"


###########################################
# getting jcraig ocean samples fastq files
###########################################

if [[ -e $RESEARCH_DRIVE/samples/MGYS00000974 ]]; then
echo "WARNING: File directory samples/MGYS00000974 already exists, no new directory will be created!"
else mkdir $RESEARCH_DRIVE/samples && mkdir $RESEARCH_DRIVE/samples/MGYS00000974
fi

for i in ERR{833272..833616}; do
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR833/$i/$i\_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR833/$i/$i\_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR833/$i/$i.fastq.gz
mv $i\_1.fastq.gz $RESEARCH_DRIVE/samples/MGYS00000974
mv $i\_2.fastq.gz $RESEARCH_DRIVE/samples/MGYS00000974
mv $i.fastq.gz $RESEARCH_DRIVE/samples/MGYS00000974
done


#############################################
# getting IR1 NCBI files (assemblies, etc)
#############################################

if [[ -e $RESEARCH_DRIVE/IR1 ]]; then
echo "WARNING: File directory IR1 already exists, no new directory will be created!"
else mkdir $RESEARCH_DRIVE/IR1
fi

#get protein assembly
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/277/835/GCA_002277835.1_ASM227783v1/GCA_002277835.1_ASM227783v1_protein.faa.gz
mv GCA_002277835.1_ASM227783v1_protein.faa.gz $RESEARCH_DRIVE/IR1/
gunzip $RESEARCH_DRIVE/IR1/GCA_002277835.1_ASM227783v1_protein.faa.gz

#get genome assembly fasta format
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/277/835/GCA_002277835.1_ASM227783v1/GCA_002277835.1_ASM227783v1_genomic.fna.gz
mv GCA_002277835.1_ASM227783v1_genomic.fna.gz $RESEARCH_DRIVE/IR1/
gunzip $RESEARCH_DRIVE/IR1/GCA_002277835.1_ASM227783v1_genomic.fna.gz

#get genome assembly gff format
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/277/835/GCA_002277835.1_ASM227783v1/GCA_002277835.1_ASM227783v1_genomic.gff.gz
mv GCA_002277835.1_ASM227783v1_genomic.gff.gz $RESEARCH_DRIVE/IR1/
gunzip $RESEARCH_DRIVE/IR1/GCA_002277835.1_ASM227783v1_genomic.gff.gz

#get genome assembly gtf format
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/277/835/GCA_002277835.1_ASM227783v1/GCA_002277835.1_ASM227783v1_genomic.gtf.gz
mv GCA_002277835.1_ASM227783v1_genomic.gtf.gz $RESEARCH_DRIVE/IR1/
gunzip $RESEARCH_DRIVE/IR1/GCA_002277835.1_ASM227783v1_genomic.gtf.gz


##################################################
#getting compost metagenomes with M17 blast hit
##################################################
source ~/anaconda3/etc/profile.d/conda.sh
conda activate sratoolkit

if [[ -e $RESEARCH_DRIVE/samples/compost_genomes ]]; then
echo "WARNING: File directory samples/compost_genomes already exists, no new directory will be created!"
else mkdir $RESEARCH_DRIVE/samples/compost_genomes
fi

#hit 1
wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778149/SRR7778149.1
fastq-dump --split-files SRR7778149.1
rm SRR7778149.1
mv SRR7778149.1* $RESEARCH_DRIVE/samples/compost_genomes/

#hit 2
wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778154/SRR7778154.1
fastq-dump --split-files SRR7778154.1
rm SRR7778154.1
mv SRR7778154.1* $RESEARCH_DRIVE/samples/compost_genomes/

#hit 3
wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778161/SRR7778161.1
fastq-dump --split-files SRR7778161.1
rm SRR7778161.1
mv SRR7778161.1* $RESEARCH_DRIVE/samples/compost_genomes/

#hit 4
wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos/sra-pub-run-1/SRR7778152/SRR7778152.1
fastq-dump --split-files SRR7778152.1
rm SRR7778152.1
mv SRR7778152.1* $RESEARCH_DRIVE/samples/compost_genomes/

#hit 5 is a protein from the same metagenome as hit 2, does hit 2 metagenome contain both gliding genes or analysis error?
