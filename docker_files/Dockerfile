# Base Image
FROM continuumio/miniconda3:4.6.14
LABEL authors="Xiandong Meng" \
      description="CoPTR is a tool for estimating peak-to-trough ratios from metagenomic sequencing." \
      software.name="CoPTR" \
      software.description="" \
      software.website="https://coptr.readthedocs.io" \
      container.category="tool"


# Update conda to latest version.
RUN conda update -n base -c defaults conda

RUN conda config --env --append channels anaconda
RUN conda config --env --append channels conda-forge
RUN conda config --env --append channels bioconda

# Install software
RUN git clone https://github.com/tyjo/coptr && \
    cd coptr/ && \
    conda install --freeze-installed -y bowtie2=2.4.1 matplotlib=3.3.2 matplotlib-base=3.3.2 numpy=1.19.1 pysam=0.16.0.1 python=3.7.8 python_abi=3.7 \
    scipy=1.5.2 sphinx=3.2.1 sphinx_rtd_theme=0.4.3 sphinxcontrib-applehelp=1.0.2 sphinxcontrib-devhelp=1.0.2 \
    sphinxcontrib-htmlhelp=1.0.3 sphinxcontrib-jsmath=1.0.1 sphinxcontrib-qthelp=1.0.3 sphinxcontrib-serializinghtml=1.1.4 && \
    pip install .


RUN mkdir -p /work
WORKDIR /work

COPY . .
