# Date: 16-Oct-2019

#activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate megahit
# Test if active
megahit -v

if [ ! -d /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit ]; then
    mkdir /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit
fi

#-616
for i in ERR{833272..833616}; do
if [ -e research_drive/geodescent/samples/MGYS00000974/$i\_1.fastq.gz ]; then
    megahit -1 /home/$USER/research_drive/geodescent/samples/MGYS00000974/$i\_1.fastq.gz \
    -2 /home/$USER/research_drive/geodescent/samples/MGYS00000974/$i\_2.fastq.gz \
    --out-dir /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit/$i
fi
if [ -e research_drive/geodescent/samples/MGYS00000974/$i.fastq.gz ]; then
    megahit -r research_drive/geodescent/samples/MGYS00000974/$i.fastq.gz \
    --out-dir /home/$USER/research_drive/geodescent/samples/MGYS00000974/megahit/$i
fi
done
