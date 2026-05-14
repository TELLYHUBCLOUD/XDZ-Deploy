# =========================================================
# WZML-X Optimized Dockerfile for Heroku
# With Mega SDK Python Bindings Support
# =========================================================

FROM python:3.10-slim-bookworm

# =========================================================
# Environment Variables
# =========================================================

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PATH="/usr/local/bin:$PATH"

WORKDIR /usr/src/app

# =========================================================
# Install System Dependencies
# =========================================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    aria2 \
    qbittorrent-nox \
    ffmpeg \
    p7zip-full \
    unzip \
    libmagic1 \
    libglib2.0-0 \
    build-essential \
    python3-dev \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libsodium-dev \
    libssl-dev \
    swig \
    ca-certificates \
    gnupg \
    procps \
    && rm -rf /var/lib/apt/lists/*

# =========================================================
# Install Mega SDK Python Bindings
# =========================================================

ENV MEGA_SDK_VERSION=10.13.0

RUN git clone --depth=1 -b v${MEGA_SDK_VERSION} \
    https://github.com/meganz/sdk.git /home/sdk && \
    mkdir -p /home/sdk/build && \
    cd /home/sdk/build && \
    cmake .. \
    -DENABLE_PYTHON=ON \
    -DENABLE_JAVA=OFF \
    -DENABLE_EXAMPLES=OFF \
    -DUSE_CRYPTOPP=OFF && \
    make -j2 && \
    cd ../bindings/python && \
    python3 setup.py bdist_wheel && \
    pip3 install dist/*.whl && \
    rm -rf /home/sdk

# =========================================================
# Install rclone
# =========================================================

RUN curl https://rclone.org/install.sh | bash

# =========================================================
# Install uv
# =========================================================

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

# =========================================================
# Create Non-Root User
# =========================================================

RUN useradd -m botuser && \
    chown -R botuser:botuser /usr/src/app && \
    chmod -R 777 /usr/src/app

ENV HOME=/home/botuser

# =========================================================
# Binary Aliases
# =========================================================

RUN ln -sf $(which qbittorrent-nox) /usr/local/bin/stormtorrent && \
    ln -sf $(which aria2c) /usr/local/bin/blitzfetcher && \
    ln -sf $(which ffmpeg) /usr/local/bin/mediaforge && \
    ln -sf $(which rclone) /usr/local/bin/ghostdrive

# =========================================================
# Switch User
# =========================================================

USER botuser

# =========================================================
# Create Virtual Environment
# =========================================================

RUN uv venv --system-site-packages .venv

ENV PATH="/usr/src/app/.venv/bin:$PATH"

# =========================================================
# Install Python Requirements
# =========================================================

COPY requirements.txt .

RUN uv pip install --no-cache-dir -r requirements.txt

# =========================================================
# Copy Project Files
# =========================================================

COPY . .

# =========================================================
# Start Application
# =========================================================

CMD ["bash", "start.sh"]
