FROM irisxdr/neo-wzml:latest

WORKDIR /usr/src/app

COPY requirements.txt .

RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN uv pip install -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
