# Base image https://hub.docker.com/u/rocker/
FROM rocker/geospatial

RUN apt-get update \
	&& apt-get install -y wget libxml-libxml-perl

RUN apt-get update \
  && apt-get install -y libany-uri-escape-perl

RUN wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.10.0/sratoolkit.2.10.0-ubuntu64.tar.gz -O /tmp/sratoolkit.tar.gz \
	&& tar zxvf /tmp/sratoolkit.tar.gz -C /opt/ && rm /tmp/sratoolkit.tar.gz

ENV PATH="/opt/sratoolkit.2.10.0-ubuntu64/bin/:${PATH}"


RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ncbi-blast+


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


RUN wget https://data.qiime2.org/distro/core/qiime2-2019.7-py36-linux-conda.yml && \
    conda env create -n qiime2-2019.7 --file qiime2-2019.7-py36-linux-conda.yml && \
    rm qiime2-2019.7-py36-linux-conda.yml


RUN conda create --name q2-metaphlan2 && \
    conda install -c fasnicar -c bioconda q2-metaphlan2 -n q2-metaphlan2

RUN echo "export PATH=/opt/conda/envs/q2-metaphlan2/bin:/opt/conda/envs/q2-metaphlan2/lib/python3.5/site-packages/q2_metaphlan2-2.7.8-py3.5.egg-info/scripts:/opt/sratoolkit.2.10.0-ubuntu64/bin:\${PATH}" >> /etc/bash.bashrc
#RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> /etc/bash.bashrc

RUN export TMPDIR='~/tmp'