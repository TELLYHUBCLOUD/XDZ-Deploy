FROM irisxdr/neo-wzml:latest

WORKDIR /usr/src/app

COPY . .

CMD ["bash", "start.sh"]
