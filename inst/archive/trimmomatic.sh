for i in ERR{833272..833285}; do
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE research_drive/geodescent/samples/MGYS00000974/$i\_1.fastq.gz research_drive/geodescent/samples/MGYS00000974/$i\_2.fastq.gz \
research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_forward_paired.fq.gz research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_forward_unpaired.fq.gz \
research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_reverse_paired.fq.gz research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_reverse_unpaired.fq.gz \
MINLEN:100 SLIDINGWINDOW:4:25 -phred33

java -jar Trimmomatic-0.39/trimmomatic-0.39.jar SE research_drive/geodescent/samples/MGYS00000974/$i.fastq.gz \
research_drive/geodescent/samples/MGYS00000974/trimmed/$i\_out.fq.gz MINLEN:100 SLIDINGWINDOW:4:25 -phred33
done