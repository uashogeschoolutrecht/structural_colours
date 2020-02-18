source /opt/conda/etc/profile.d/conda.sh
conda activate sratoolkit

while getopts a: aflag
do
case "${aflag}"
in
a) ACC=${OPTARG};;
esac
done

prefetch ${ACC}
echo "${ACC}\t$(md5sum ~/ncbi/public/sra/${ACC}*)" >> md5.txt
fastq-dump --split-files ${ACC}
