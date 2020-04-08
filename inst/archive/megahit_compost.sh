# Date: 16-Oct-2019

#activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate megahit
# Test if active
megahit -v

if [ ! -d /home/$USER/research_drive/geodescent/samples/MGYS00005036/megahit ]; then
    mkdir /home/$USER/research_drive/geodescent/samples/MGYS00005036/megahit
fi

#-616
for i in SRR{6231165..6231221}; do
if [ -e research_drive/geodescent/samples/MGYS00005036/$i\_1.fastq.gz ]; then
    megahit -1 /home/$USER/research_drive/geodescent/samples/MGYS00005036/$i\_1.fastq.gz \
    -2 /home/$USER/research_drive/geodescent/samples/MGYS00005036/$i\_2.fastq.gz \
    --out-dir /home/$USER/data/geodescent/samples/MGYS00005036/megahit/$i
fi
if [ -e research_drive/geodescent/samples/MGYS00005036/$i.fastq.gz ]; then
    megahit -r research_drive/geodescent/samples/MGYS00005036/$i.fastq.gz \
    --out-dir /home/$USER/data/geodescent/samples/MGYS00005036/megahit/$i
fi
done
