FROM python:3.10-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

WORKDIR /usr/src/app

# Runtime packages only
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
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Build deps only for Mega SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    git \
    && rm -rf /var/lib/apt/lists/*

ENV MEGA_SDK_VERSION=10.13.0

RUN git clone --depth=1 -b v${MEGA_SDK_VERSION} \
    https://github.com/meganz/sdk.git /tmp/sdk && \
    mkdir -p /tmp/sdk/build && \
    cd /tmp/sdk/build && \
    cmake .. \
    -DENABLE_PYTHON=ON \
    -DENABLE_JAVA=OFF \
    -DENABLE_EXAMPLES=OFF \
    -DUSE_CRYPTOPP=OFF && \
    make -j2 && \
    cd ../bindings/python && \
    python3 setup.py bdist_wheel && \
    pip3 install dist/*.whl && \
    rm -rf /tmp/sdk

# Remove heavy build packages after compile
RUN apt-get purge -y \
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
    swig && \
    apt-get autoremove -y && \
    apt-get clean

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

# User
RUN useradd -m botuser

ENV HOME=/home/botuser

RUN chown -R botuser:botuser /usr/src/app

USER botuser

# Venv
RUN uv venv --system-site-packages .venv

ENV PATH="/usr/src/app/.venv/bin:$PATH"

COPY requirements.txt .

RUN uv pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
