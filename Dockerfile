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
    cmake \
    libssl-dev \
    zlib1g-dev \
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

# Install heavy Python packages with Mamba
RUN mamba install -n py_env -y -c conda-forge \
    numpy \
    scipy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    tensorflow \
    xgboost \
    lightgbm \
    statsmodels \
    nltk \
    spacy \
    dask \
    gensim \
    geopandas \
    shap \
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

# Download large models/data
RUN /bin/bash -c "source activate py_env && \
    python -m spacy download en_core_web_lg && \
    python -m nltk.downloader popular"

# Configure Jupyter
RUN /bin/bash -c "source activate py_env && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextensions_configurator enable --sys-prefix && \
    jupyter lab build --minimize=False"

# ===================================================================
# CPU-intensive tasks (customize these based on your needs)
# ===================================================================

# 1. Compile Redis from source (CPU-bound build task)
RUN wget -q https://download.redis.io/releases/redis-7.2.4.tar.gz && \
    tar xzf redis-7.2.4.tar.gz && \
    cd redis-7.2.4 && \
    make -j$(nproc) BUILD_TLS=yes

# 2. Run cryptographic benchmarks (CPU-bound runtime task)
RUN apt-get update && apt-get install -y --no-install-recommends openssl && \
    rm -rf /var/lib/apt/lists/*
RUN for i in 1 2 3; do \
        openssl speed rsa4096 ecdsap521 sha512 > /dev/null; \
    done

# 3. Build and run a CPU-intensive Go benchmark
RUN apt-get update && apt-get install -y --no-install-recommends golang && \
    rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/golang/go && \
    cd go/test/bench/go1 && \
    go test -bench=. -benchtime=10s -cpu=1,2,4,8

# 4. Kubernetes-related CPU test (kube-burner)
RUN wget -q https://github.com/cloud-bulldozer/kube-burner/releases/download/v1.7.3/kube-burner-1.7.3-Linux-x86_64.tar.gz && \
    tar xvf kube-burner-1.7.3-Linux-x86_64.tar.gz && \
    ./kube-burner init -c https://raw.githubusercontent.com/cloud-bulldozer/kube-burner/main/examples/node-density.yml \
        -u http://localhost:8080 -m node-density

# 5. Synthetic CPU benchmark (sysbench)
RUN apt-get update && apt-get install -y --no-install-recommends sysbench && \
    rm -rf /var/lib/apt/lists/*
RUN sysbench cpu --cpu-max-prime=20000 --threads=$(nproc) run

# 6. Compression benchmark (multi-core)
RUN apt-get update && apt-get install -y --no-install-recommends zstd pbzip2 && \
    rm -rf /var/lib/apt/lists/*
RUN wget -q https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.8.tar.xz && \
    tar -xf linux-6.8.8.tar.xz && \
    cd linux-6.8.8 && \
    find . -type f | xargs -P$(nproc) -I{} zstd -19 -T0 {} -o /dev/null

# ===================================================================

# Create workspace directory
RUN mkdir /workspace
WORKDIR /workspace

# Set default command
CMD ["/bin/bash", "-c", "source activate py_env && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"]
