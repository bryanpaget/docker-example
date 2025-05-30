# Dockerfile
FROM ubuntu:22.04

# Disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    software-properties-common \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    unzip \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    tk-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    libblas-dev \
    liblapack-dev \
    gfortran \
    libcurl4-openssl-dev \
    libopenblas-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libicu-dev \
    libgsl-dev \
    libudunits2-dev \
    libproj-dev \
    libgeos-dev \
    libgdal-dev \
    libcairo2-dev \
    libxt-dev \
    openjdk-11-jdk \
    fonts-dejavu \
    tzdata \
    locales \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Install R with manual key installation
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends dirmngr gnupg2 && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add - && \
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | tee -a /etc/apt/sources.list.d/r.list && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends r-base r-base-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python data science packages (with versions that require compilation)
RUN python3.10 -m pip --no-cache-dir install \
    jupyterlab==4.0.10 \
    numpy==1.26.4 \
    pandas==2.2.1 \
    scipy==1.13.0 \
    matplotlib==3.8.3 \
    seaborn==0.13.2 \
    scikit-learn==1.4.1.post1 \
    tensorflow==2.16.1 \
    torch==2.2.1 \
    torchvision==0.17.1 \
    torchaudio==2.2.1 \
    xgboost==2.0.3 \
    lightgbm==4.3.0 \
    statsmodels==0.14.1 \
    nltk==3.8.1 \
    spacy==3.7.4 \
    plotly==5.20.0 \
    dash==2.16.1 \
    bokeh==3.4.0 \
    dask==2024.5.1 \
    pystan==3.9.0 \
    prophet==1.1.5 \
    pycaret==3.3.0 \
    opencv-python-headless==4.9.0.80 \
    keras==3.1.1 \
    transformers==4.40.0 \
    datasets==2.19.0 \
    gensim==4.3.2 \
    networkx==3.2.1 \
    sympy==1.12 \
    geopandas==0.14.3 \
    shap==0.45.1 \
    streamlit==1.32.2 \
    fastapi==0.110.0 \
    uvicorn==0.29.0 \
    && python3.10 -m spacy download en_core_web_lg \
    && python3.10 -m nltk.downloader all

# Install R packages (with comprehensive list)
RUN R -e "install.packages(c('tidyverse', 'rmarkdown', 'knitr', 'data.table', 'lubridate', \
    'caret', 'randomForest', 'xgboost', 'glmnet', 'dbscan', 'factoextra', \
    'igraph', 'ggraph', 'shiny', 'shinydashboard', 'plotly', 'leaflet', \
    'lme4', 'brms', 'rstan', 'forecast', 'prophet', 'survival', 'mlr3', \
    'tidymodels', 'BiocManager', 'devtools'), repos='https://cran.rstudio.com/')" && \
    R -e "BiocManager::install(c('DESeq2', 'limma', 'edgeR', 'Biobase', \
    'GenomicRanges', 'SummarizedExperiment', 'AnnotationDbi'))" && \
    R -e "IRkernel::installspec()"

# Install Jupyter extensions
RUN python3.10 -m pip --no-cache-dir install \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator \
    jupyterlab-git \
    jupyterlab-lsp \
    jupyterlab_code_formatter \
    jupyterlab_widgets \
    ipywidgets \
    jupyterlab-vim \
    jupyterlab-drawio

# Configure Jupyter
RUN jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    jupyter lab build --minimize=False  # Disable minimization to increase build time

# Create workspace directory
RUN mkdir /workspace
WORKDIR /workspace

# Default command
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
