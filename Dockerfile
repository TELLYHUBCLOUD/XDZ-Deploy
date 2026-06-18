FROM irisxdr/neo-wzml:latest

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN chmod 777 /usr/src/app

COPY requirements.txt .

RUN uv pip install --system --no-cache-dir -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
