FROM ubuntu:20.04

LABEL maintainer="scanon@lbl.gov"
LABEL us.kbase.ubuntu="20.04"
LABEL us.kbase.python="3.10"
LABEL us.kbase.sdk="1.0.18"

RUN \
    apt-get -y update && \
    export DEBIAN_FRONTEND=noninteractive && \
    export TZ=Etc/UTC && \
    apt-get -y install gcc make curl git openjdk-8-jre

# Copy in the SDK
COPY --from=kbase/kb-sdk:20180808 /src /sdk
RUN sed -i 's|/src|/sdk|g' /sdk/bin/*

# Install Conda version py39_4.12.0
RUN \
    V=py39_4.12.0 && \
    curl -o conda.sh -s https://repo.anaconda.com/miniconda/Miniconda3-${V}-Linux-x86_64.sh && \
    sh ./conda.sh -b -p /opt/conda3 && \
    rm conda.sh
    

ENV PATH=/opt/conda3/bin:$PATH:/sdk/bin

# Fix output for pip installations
ENV PIP_PROGRESS_BAR=off

# Install packages including mamba
RUN \
    conda install -c conda-forge mamba

ADD ./requirements.txt /tmp/
RUN \
    pip install -r /tmp/requirements.txt

# Add in some legacy modules
ADD biokbase /opt/conda3/lib/python3.8/site-packages/biokbase
ADD biokbase/user-env.sh /kb/deployment/user-env.sh
