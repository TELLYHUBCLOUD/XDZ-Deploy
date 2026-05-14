# Use Python 3.10 slim
FROM python:3.10-slim-bookworm

# Environment variables
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
    && rm -rf /var/lib/apt/lists/*

# Installing Mega SDK Python Binding
ENV MEGA_SDK_VERSION="10.13.0"
RUN git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk \
    && cd ~/home/sdk && rm -rf .git \
    && autoupdate -fIv && ./autogen.sh \
    && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl 

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

# Create non-root user
RUN useradd -m botuser && \
    chown -R botuser:botuser /usr/src/app && \
    chmod -R 777 /usr/src/app

# Home path for MegaCMD
ENV HOME=/home/botuser

# Binary aliases
RUN ln -sf $(which qbittorrent-nox) /usr/local/bin/stormtorrent && \
    ln -sf $(which aria2c) /usr/local/bin/blitzfetcher && \
    ln -sf $(which ffmpeg) /usr/local/bin/mediaforge && \
    ln -sf $(which rclone) /usr/local/bin/ghostdrive

# Switch user
USER botuser

# Create virtual environment
RUN uv venv --system-site-packages .venv

# Activate venv automatically
ENV PATH="/usr/src/app/.venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .

RUN uv pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Verify MegaCMD
RUN mega-version

# Start command
CMD ["bash", "start.sh"]
