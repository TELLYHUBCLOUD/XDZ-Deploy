FROM tellyhubcloud/tellyhubcloud:dev

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1

WORKDIR /usr/src/app

# Copy UV binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install requirements
COPY requirements.txt .
RUN pip3 install --break-system-packages --no-cache-dir -r requirements.txt

# Copy app
COPY . .
RUN chmod -R 777 /usr/src/app

# Start
CMD ["bash", "start.sh"]
