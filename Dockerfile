FROM tellyhubcloud/wzmlxdz:main
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# gcc install for compiling tgcrypto, phir remove
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python3.13-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN uv venv --system-site-packages
COPY requirements.txt .
RUN uv pip install --no-cache-dir -r requirements.txt

COPY . .
ENV PATH="/usr/src/app/.venv/bin:$PATH"
CMD ["bash", "start.sh"]
