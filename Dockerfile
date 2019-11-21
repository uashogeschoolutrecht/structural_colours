# Base image https://hub.docker.com/u/rocker/
FROM rocker/geospatial

RUN apt-get update && \
    apt-get install -y --no-install-recommends ncbi-blast+ && \
    apt-get install -y perl

RUN wget http://downloads.sourceforge.net/project/bbmap/BBMap_38.69.tar.gz -O /tmp/BBMap && \
    tar -xvzf /tmp/BBMap -C /opt/ && rm /tmp/BBMap

## Copy requirements.R to container directory /tmp
COPY ./DockerConfig/requirements.R /tmp/requirements.R
## install required libs on container
RUN Rscript /tmp/requirements.R

# create an R user
ENV USER rstudio

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8


ENV PATH="/opt/conda/bin:${PATH}"

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

#RUN conda create -n q2-metaphlan2 -c fasnicar -c bioconda q2-metaphlan2

RUN wget https://data.qiime2.org/distro/core/qiime2-2019.7-py36-linux-conda.yml && \
    conda env create -n qiime2-2019.7 --file qiime2-2019.7-py36-linux-conda.yml && \
    rm qiime2-2019.7-py36-linux-conda.yml

RUN conda create -n sratoolkit -c bioconda sra-tools

RUN wget http://cab.spbu.ru/files/release3.12.0/SPAdes-3.12.0-Linux.tar.gz && \
    tar -xzf SPAdes-3.12.0-Linux.tar.gz

RUN conda create -n megahit -c bioconda megahit

#RUN wget https://netcologne.dl.sourceforge.net/project/biogrinder/biogrinder/Grinder-0#.5.4/Grinder-0.5.4.tar.gz && \
#    tar -xzf Grinder-0.5.4.tar.gz && \
#    perl -y /Grinder-0.5.4/Makefile.PL
#    #make --makefile /Grinder-0.5.4/Makefile.PL
    
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

#USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && (apt-get install -t buster-backports -y grinder || apt-get install -y grinder) && apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/*

#RUN mkdir /usr/share/perl5/Math/Random/ && \
#    mv /usr/lib/x86_64-linux-gnu/perl5/5.24/Math/Random/MT.pm /usr/share/perl5/Math/Random/
#RUN echo "export PERL5LIB=/usr/share/perl5:$PERL5LIB" >> /etc/bash.bashrc


#RUN wget https://downloads.sourceforge.net/project/quast/quast-5.0.2.tar.gz && \
#    tar -xzf quast-5.0.2.tar.gz

    
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip fastqc_v0.11.8.zip

RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip && \
    unzip Trimmomatic-0.39.zip

RUN echo "export PATH=/bin:/SPAdes-3.12.0-Linux/bin:/opt/bbmap:/opt/conda/envs/q2-metaphlan2/bin:/opt/conda/envs/q2-metaphlan2/lib/python3.5/site-packages/q2_metaphlan2-2.7.8-py3.5.egg-info/scripts:/opt/sratoolkit.2.10.0-ubuntu64/bin:\${PATH}" >> /etc/bash.bashrc
RUN echo "export TMPDIR=/tmp" >> /etc/bash.bashrc
RUN touch /home/$USER/.Renviron
RUN echo "R_LIBS=/opt/conda/envs/qiime2-2019.7/lib/R/library:\${R_LIBS}" >> /home/$USER/.Renviron

RUN apt-get update
RUN apt-get install -y perl && \
    apt-get install -y liblist-moreutils-perl && \
    apt-get install -y libmath-random-mt-perl && \
    apt-get install -y libbio-perl-perl && \
    apt-get install -y libgetopt-euclid-perl
    


#https://hub.docker.com/r/rocker/shiny/dockerfile

RUN conda create -n krona -c bioconda krona 

RUN conda create -n prokka -c conda-forge -c bioconda -c defaults prokka

RUN apt-get update && \
    apt-get install -y build-essential libboost-all-dev git cmake curl libncurses5-dev zlib1g-dev

RUN conda create -n metabat2 -c bioconda metabat2
#RUN git clone https://bitbucket.org/berkeleylab/metabat.git
#RUN cd metabat && \
#    mkdir build && \
#    cd build && \
#    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
#    make -j8 && \
#    make install && \
#    cd .. && \
#    rm -rf build
