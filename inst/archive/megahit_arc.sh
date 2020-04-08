# Date: 16-Oct-2019

#activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate megahit
# Test if active
megahit -v

if [ ! -d /home/$USER/data/geodescent/samples/MGYS00000991/megahit ]; then
    mkdir /home/$USER/data/geodescent/samples/MGYS00000991/megahit
fi

file="/home/rstudio/acc_list"
while IFS= read -r i
do
    echo $i

if [ -e /home/rstudio/data/geodescent/samples/MGYS00000991/$i\_1.fastq.gz ]; then
    megahit -1 /home/$USER/data/geodescent/samples/MGYS00000991/$i\_1.fastq.gz \
    -2 /home/$USER/data/geodescent/samples/MGYS00000991/$i\_2.fastq.gz \
    --out-dir /home/$USER/data/geodescent/samples/MGYS00000991/megahit/$i
fi
done <"$file"
