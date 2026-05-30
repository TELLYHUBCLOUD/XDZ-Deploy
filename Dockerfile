FROM tellyhubcloud/tellyhubcloud:dev

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# Copy UV binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install requirements
COPY requirements.txt .
RUN uv pip install --python /usr/bin/python3.13 --break-system-packages --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Set executable permissions
RUN chmod +x start.sh

# Start the application
CMD ["bash", "start.sh"]
