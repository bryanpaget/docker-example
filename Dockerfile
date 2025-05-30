# Dockerfile
FROM ubuntu:22.04

# Install basic utilities
RUN apt-get update && \
    apt-get install -y wget unzip

# Download and extract a large dataset (GeoLite2 database)
RUN wget -q https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb && \
    wget -q https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb

# Create a 1GB dummy file
RUN dd if=/dev/zero of=/dummyfile bs=1M count=1000

# Cleanup (optional)
RUN rm -rf /var/lib/apt/lists/*
