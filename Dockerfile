FROM ubuntu:20.04

# Note that these labels need to be manually updated with the actual contents of the image
LABEL maintainer="scanon@lbl.gov"
LABEL us.kbase.ubuntu="20.04"
LABEL us.kbase.python="3.9.12"
LABEL us.kbase.sdk="1.2.1"
LABEL us.kbase.sdkcommit="8def489f648a7ff5657d33ed05f41c60f4766e1b"

# Fix KBase Catalog Registration Issue
ENV PIP_PROGRESS_BAR=off

# Install system dependencies
RUN \
    apt-get -y update && \
    apt-get -y upgrade && \
    export DEBIAN_FRONTEND=noninteractive && \
    export TZ=Etc/UTC && \
    apt-get -y install gcc make curl git openjdk-8-jre unzip htop

# Copy in the SDK
COPY --from=kbase/kb-sdk:1.2.1 /src /sdk
RUN sed -i 's|/src|/sdk|g' /sdk/bin/*


# Install Conda version py39_4.12.0 and Python 3.9.12
ENV CONDA_VERSION=py39_4.12.0
ENV CONDA_INSTALL_DIR=/opt/conda{CONDA_VERSION}

RUN \
    curl -o conda.sh -s https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh && \
    sh ./conda.sh -b -p ${CONDA_INSTALL_DIR} && \
    rm conda.sh

# Add in some legacy modules
ENV BIOKBASE_INSTALL_DIR=${CONDA_INSTALL_DIR}/lib/python3.9/site-packages/biokbase
ADD biokbase ${BIOKBASE_INSTALL_DIR}
ADD biokbase/user-env.sh /kb/deployment/user-env.sh


# Configure Conda and Install packages 
RUN \
    conda config --add channels conda-forge \
    conda config --set channel_priority strict \
    conda install -y mamba=0.15.3 \
