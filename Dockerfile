FROM tellyhubcloud/tellyhubcloud:dev

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    LD_LIBRARY_PATH="/usr/local/lib"

WORKDIR /usr/src/app

# Copy UV binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install requirements
COPY requirements.txt .
RUN uv pip install --system --no-cache-dir -r requirements.txt

# Copy app
COPY . .
RUN chmod -R 777 /usr/src/app

CMD ["bash", "start.sh"]
