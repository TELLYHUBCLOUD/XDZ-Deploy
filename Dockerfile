FROM python:3.10-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

WORKDIR /usr/src/app

# Minimal runtime packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    aria2 \
    ffmpeg \
    p7zip-full \
    unzip \
    libmagic1 \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install qBittorrent separately with minimal recommends disabled
RUN apt-get update && apt-get install -y --no-install-recommends \
    qbittorrent-nox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    autoconf \
    automake \
    libtool \
    gcc \
    g++ \
    python3-dev \
    libsodium-dev \
    libssl-dev \
    swig \
    && rm -rf /var/lib/apt/lists/*

# Install Mega SDK
ENV MEGA_SDK_VERSION=4.8.0

RUN git clone --depth=1 -b v${MEGA_SDK_VERSION} \
    https://github.com/meganz/sdk.git /tmp/sdk && \
    mkdir /tmp/sdk/build && \
    cd /tmp/sdk/build && \
    cmake .. \
      -DENABLE_PYTHON=ON \
      -DENABLE_JAVA=OFF \
      -DENABLE_EXAMPLES=OFF \
      -DUSE_CRYPTOPP=OFF && \
    make -j2 && \
    cd ../bindings/python && \
    python3 setup.py bdist_wheel && \
    pip install dist/*.whl && \
    rm -rf /tmp/sdk

# Remove build dependencies completely
RUN apt-get purge -y \
    build-essential \
    cmake \
    pkg-config \
    autoconf \
    automake \
    libtool \
    gcc \
    g++ \
    python3-dev \
    libsodium-dev \
    libssl-dev \
    swig && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

RUN useradd -m botuser

ENV HOME=/home/botuser

COPY requirements.txt .

RUN uv venv --system-site-packages .venv && \
    . .venv/bin/activate && \
    uv pip install -r requirements.txt

COPY . .

RUN chown -R botuser:botuser /usr/src/app

USER botuser

ENV PATH="/usr/src/app/.venv/bin:$PATH"

CMD ["bash", "start.sh"]
