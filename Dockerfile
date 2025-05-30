# Dockerfile
FROM ubuntu:22.04

# Disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    ca-certificates \
    fonts-dejavu \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Mambaforge
RUN wget -q https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-Linux-x86_64.sh && \
    bash Miniforge3-25.3.0-3-Linux-x86_64.sh -b -p /opt/mambaforge && \
    rm Miniforge3-25.3.0-3-Linux-x86_64.sh 
ENV PATH="/opt/mambaforge/bin:${PATH}"

# Create and activate conda environment
RUN mamba create -n py_env python=3.10 jupyterlab=4.0.10 -y -c conda-forge

# Install heavy Python packages with Mamba (selected for size/compilation time)
RUN mamba install -n py_env -y -c conda-forge \
    numpy=1.26 \
    scipy=1.13 \
    pandas=2.1 \
    matplotlib=3.8 \
    seaborn=0.13 \
    scikit-learn=1.4 \
    tensorflow=2.16 \
    xgboost=2.0 \
    lightgbm=4.3 \
    statsmodels=0.14 \
    nltk=3.8 \
    spacy=3.7 \
    bokeh=3.4 \
    dask=2024.5 \
    gensim=4.3 \
    geopandas=0.14 \
    shap=0.45 \
    jupyterlab-git \
    jupyterlab-lsp \
    jupyterlab_code_formatter \
    jupyterlab_widgets \
    ipywidgets \
    notebook \
    && mamba clean -y --all

# Install Jupyter extensions
RUN mamba install -n py_env -y -c conda-forge \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator \
    && mamba clean -y --all

# Install R and heavy R packages
RUN mamba install -n py_env -y -c conda-forge \
    r-base=4.3 \
    r-tidyverse=2.0 \
    r-rmarkdown=2.25 \
    r-knitr=1.45 \
    r-caret=6.0 \
    r-randomforest=4.7 \
    r-xgboost=1.7 \
    r-glmnet=4.1 \
    r-plotly=4.10 \
    r-leaflet=2.2 \
    r-forecast=8.21 \
    r-prophet=1.0 \
    r-devtools=2.4 \
    r-biocmanager=1.30 \
    r-irkernel=1.3 \
    && mamba clean -y --all

# Download large models/data
RUN /bin/bash -c "source activate py_env && \
    python -m spacy download en_core_web_lg && \
    python -m nltk.downloader popular"

# Configure Jupyter
RUN /bin/bash -c "source activate py_env && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextensions_configurator enable --sys-prefix && \
    jupyter lab build --minimize=False"

# Create workspace directory
RUN mkdir /workspace
WORKDIR /workspace

# Set default command
CMD ["/bin/bash", "-c", "source activate py_env && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"]
