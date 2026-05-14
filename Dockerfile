# Use Python 3.13 slim as the base image
FROM python:3.13-slim-bookworm

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/bin:$PATH"

WORKDIR /usr/src/app

# Install system dependencies
# We include build-essential for compiling some python wheels like tgcrypto and uvloop
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
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
    && curl -O https://mega.nz/linux/repo/xUbuntu_22.04/amd64/megacmd-xUbuntu_22.04_amd64.deb\
    && apt-get install -y ./megacmd-xUbuntu_22.04_amd64.deb    
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install rclone from the official script
RUN curl https://rclone.org/install.sh | bash

# Install uv for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

# Create a non-root user for better security
RUN useradd -m botuser && \
    chown -R botuser:botuser /usr/src/app && \
    chmod 777 /usr/src/app

# Set up binaries symlinks (for the custom names used in BinConfig)
RUN ln -sf $(which qbittorrent-nox) /usr/local/bin/stormtorrent && \
    ln -sf $(which aria2c) /usr/local/bin/blitzfetcher && \
    ln -sf $(which ffmpeg) /usr/local/bin/mediaforge && \
    ln -sf $(which rclone) /usr/local/bin/ghostdrive

# Switch to non-root user
USER botuser

# Create venv and install dependencies
RUN uv venv --system-site-packages .venv
ENV PATH="/usr/src/app/.venv/bin:$PATH"

COPY requirements.txt .
RUN uv pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Set owner for the copied files
USER root
RUN chown -R botuser:botuser /usr/src/app
USER botuser

# Healthcheck to ensure the bot process is running
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD pgrep -f "python3 -m bot" || exit 1

# Run the start script
CMD ["bash", "start.sh"]
