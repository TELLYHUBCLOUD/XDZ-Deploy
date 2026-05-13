FROM downloaderzone/mltb:latest

WORKDIR /usr/src/app
# Create a non-root user for better security
RUN useradd -m botuser && \
    chown -R botuser:botuser /usr/src/app && \
    chmod 777 /usr/src/app
RUN uv venv --system-site-packages

# Create symlinks for custom binary names used by BinConfig
RUN ln -sf $(which qbittorrent-nox) /usr/local/bin/stormtorrent && \
    ln -sf $(which aria2c) /usr/local/bin/blitzfetcher && \
    ln -sf $(which ffmpeg) /usr/local/bin/mediaforge && \
    ln -sf $(which rclone) /usr/local/bin/ghostdrive

COPY requirements.txt .
RUN uv pip install --no-cache-dir -r requirements.txt
COPY . .
# Set owner for the copied files
RUN chown -R botuser:botuser /usr/src/app
# Healthcheck to ensure the bot process is running
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD pgrep -f "python3 -m bot" || exit 1
# Run as non-root user
USER botuser
CMD ["bash", "start.sh"]
