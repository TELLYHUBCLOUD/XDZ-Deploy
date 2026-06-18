FROM irisxdr/neo-wzml:latest

WORKDIR /usr/src/app

COPY requirements.txt .

RUN uv venv
RUN . .venv/bin/activate && uv pip install -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
