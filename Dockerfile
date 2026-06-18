FROM irisxdr/neo-wzml:latest

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y gcc g++ build-essential python3-dev

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
