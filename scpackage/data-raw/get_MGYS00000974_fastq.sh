#!/usr/bin/env bash

if [[ -e ../inst/extdata/MGYS00000974_fastq/ ]]; then
echo "WARNING: File directory already exists, no new directory will be created!"
else mkdir ../inst/extdata/MGYS00000974_fastq/
fi

#ERR833272-ERR833616 = ERR{833272..833616}, for test until 276, NOTE: only paired end so far, conditional code needed
for i in ERR{833272..833276}; do
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR833/$i/$i\_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR833/$i/$i\_2.fastq.gz
mv $i\_1.fastq.gz ../inst/extdata/MGYS00000974_fastq
mv $i\_2.fastq.gz ../inst/extdata/MGYS00000974_fastq
done

#wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR833/ERR833281/ERR833281.fastq.gz
#mv ERR833281.fastq.gz ../inst/extdata/MGYS00000974_fastq
