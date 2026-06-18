FROM tellyhubcloud/tellyhubcloud:bypass

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    python3-dev

COPY requirements.txt .

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN uv pip install -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
