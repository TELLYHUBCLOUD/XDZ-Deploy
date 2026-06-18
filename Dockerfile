FROM irisxdr/neo-wzml:latest

WORKDIR /usr/src/app

COPY requirements.txt .

RUN uv pip install --system --no-cache-dir -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
