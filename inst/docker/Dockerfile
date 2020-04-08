# Base image https://hub.docker.com/u/rocker/
FROM rocker/geospatial

###### Installing required R packages #####
COPY ./DockerConfig/requirements.R /tmp/requirements.R
RUN Rscript /tmp/requirements.R


##### Create an R user #####
ENV USER rstudio
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8


##### Installing linux dependencies #####
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends ncbi-blast+ && \
    apt-get install -y perl && \
    apt-get install -y liblist-moreutils-perl && \
    apt-get install -y libmath-random-mt-perl && \
    apt-get install -y build-essential wget unzip python2.7 \
    python-dev git python-pip curl autoconf autogen libssl-dev && \
    apt-get install -y python3-pip && \
    apt-get install -y libbio-perl-perl && \
    apt-get install -y libgetopt-euclid-perl && \
    apt-get install -y build-essential libboost-all-dev git cmake curl libncurses5-dev zlib1g-dev && \
    apt-get install rsync
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


##### Installing non-conda tools #####
MAINTAINER biocontainers <biodocker@gmail.com>
LABEL    software="grinder" \
    base_image="biocontainers/biocontainers:vdebian-buster-backports_cv1" \
    container="grinder" \
    about.summary="Versatile omics shotgun and amplicon sequencing read simulator" \
    about.home="https://sourceforge.net/projects/biogrinder/" \
    software.version="0.5.4-5-deb" \
    upstream.version="0.5.4" \
    version="1" \
    about.copyright="2009-2011, Florent Angly <florent.angly@gmail.com>" \
    about.license="GPL-3+" \
    about.license_file="/usr/share/doc/grinder/copyright" \
    extra.binaries="/usr/bin/average_genome_size,/usr/bin/change_paired_read_orientation,/usr/bin/grinder" \
    about.tags=""

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && (apt-get install -t buster-backports -y grinder || apt-get install -y grinder) && apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/*

RUN wget http://downloads.sourceforge.net/project/bbmap/BBMap_38.69.tar.gz -O /tmp/BBMap && \
    tar -xvzf /tmp/BBMap -C /opt/ && rm /tmp/BBMap

RUN wget https://downloads.sourceforge.net/project/quast/quast-5.0.2.tar.gz && \
    tar -xzf quast-5.0.2.tar.gz

RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip fastqc_v0.11.8.zip && \
    chmod 755 FastQC/fastqc

RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip && \
    unzip Trimmomatic-0.39.zip

RUN cd /usr/ && \
    wget http://github.com/DerrickWood/kraken2/archive/v2.0.8-beta.tar.gz && \
    tar xzvf v2.0.8-beta.tar.gz && \
    cd kraken2-2.0.8-beta && \
    ./install_kraken2.sh /usr/local/bin/kraken2-v2.0.8 && \
    ln -s /usr/local/bin/kraken2-v2.0.8/kraken2* /usr/local/bin/ && \
    kraken2-build -h

#RUN pip3 install numpy && \
#    pip3 install pysam && \
#    pip3 install checkm-genome
#RUN echo -e "cat << EOF\n/db/CheckM\nEOF\n" | checkm data setRoot

RUN pip3 install EukRep

RUN wget http://github.com/bbuchfink/diamond/releases/download/v0.9.21/diamond-linux64.tar.gz && \
    tar xzf diamond-linux64.tar.gz && \
    mv /diamond /usr/bin

RUN wget https://github.com/dutilh/CAT/archive/v5.0.3.tar.gz && \
    tar xzf v5.0.3.tar.gz

RUN wget https://github.com/hyattpd/Prodigal/archive/v2.6.3.tar.gz && \
    tar xzf v2.6.3.tar.gz && \
    cd /Prodigal-2.6.3 && \
    make install

RUN wget ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn/linux.tbl2asn.gz && \
    gunzip linux.tbl2asn.gz && \
    mv linux.tbl2asn /bin/tbl2asn && \
    chmod +x /bin/tbl2asn

##### Installing conda package manager #####
ENV PATH="/opt/conda/bin:${PATH}"

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN conda update conda -y
RUN conda install conda-build -y
RUN conda install anaconda-client -y


##### Installing conda tools #####
RUN conda create -n q2-metaphlan2 -c fasnicar -c bioconda q2-metaphlan2
RUN conda create -n sratoolkit -c bioconda sra-tools
RUN conda create -n krona -c bioconda krona
RUN conda create -n prokka -c conda-forge -c bioconda -c defaults prokka && \
    rm -rf /opt/conda/envs/prokka/bin/tbl2asn
RUN conda create -n metabat2 -c bioconda metabat2
RUN conda create -n megahit -c bioconda megahit


##### git lfs
RUN apt-get update && \
    apt-get install -y gnupg
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get update && \
    apt-get install git-lfs
RUN git lfs install

##### Setting environment #####
RUN echo "export PATH=/bin:/CAT-5.0.3/CAT_pack:/opt/bbmap:/opt/conda/envs/q2-metaphlan2/bin:/opt/conda/envs/q2-metaphlan2/lib/python3.5/site-packages/q2_metaphlan2-2.7.8-py3.5.egg-info/scripts:/opt/sratoolkit.2.10.0-ubuntu64/bin:\${PATH}" >> /etc/bash.bashrc

