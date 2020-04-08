# Date: 16-Oct-2019

#activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate megahit
# Test if active
megahit -v


#############
# user input
#############

# input flag s (path) for single end and p for paired end (path1,path2), output name and main path dir
while getopts s:p:o:n: aflag
do
case "${aflag}"
in
s) INPUT_SE=${OPTARG};;
p) INPUT_PE=${OPTARG};;
o) OUTDIR=${OPTARG};;
n) OUTNAME=${OPTARG};;
esac
done
#splitting paired reads file paths
IFS=',' read -r PE_1 PE_2 <<< "$INPUT_PE"

if [ ! -d ${OUTDIR} ]; then
    mkdir ${OUTDIR}
fi

# if paired end option used run paired end code
if [ ! -z ${INPUT_PE+x} ]; then
    megahit -1 ${PE_1} \
    -2 ${PE_2} \
    --out-dir ${OUTDIR}/${OUTNAME}
fi

if [ ! -z ${INPUT_SE+x} ]; then
    megahit -r ${INPUT_SE} \
    --out-dir ${OUTDIR}/${OUTNAME}
fi
