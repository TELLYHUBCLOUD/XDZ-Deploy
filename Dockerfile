# Use Python 3.10 slim
FROM python:3.10-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/bin:$PATH"

WORKDIR /usr/src/app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    gnupg \
    ca-certificates \
    aria2 \
    qbittorrent-nox \
    ffmpeg \
    p7zip-full \
    unzip \
    libmagic1 \
    libglib2.0-0 \
    default-jre \
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
    && rm -rf /var/lib/apt/lists/*

# Install Mega SDK Python Binding
ENV MEGA_SDK_VERSION=10.13.0

RUN git clone --depth=1 -b v${MEGA_SDK_VERSION} https://github.com/meganz/sdk.git /home/sdk && \
    cd /home/sdk && \
    ./autogen.sh && \
    ./configure \
    --disable-silent-rules \
    --enable-python \
    --with-sodium \
    --disable-examples && \
    make -j$(nproc) && \
    cd bindings/python && \
    python3 setup.py bdist_wheel && \
    pip3 install dist/*.whl

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

# Create user
RUN useradd -m botuser && \
    chown -R botuser:botuser /usr/src/app && \
    chmod -R 777 /usr/src/app

ENV HOME=/home/botuser

# Binary aliases
RUN ln -sf $(which qbittorrent-nox) /usr/local/bin/stormtorrent && \
    ln -sf $(which aria2c) /usr/local/bin/blitzfetcher && \
    ln -sf $(which ffmpeg) /usr/local/bin/mediaforge && \
    ln -sf $(which rclone) /usr/local/bin/ghostdrive

USER botuser

# Create venv
RUN uv venv --system-site-packages .venv

ENV PATH="/usr/src/app/.venv/bin:$PATH"

COPY requirements.txt .

RUN uv pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
