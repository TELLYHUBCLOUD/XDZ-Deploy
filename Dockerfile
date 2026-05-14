FROM silentdemonsd/wzmlx:hk

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

RUN apt-get update && apt-get install -y python3-dev
RUN pip install "setuptools<67" "setuptools_scm<8" --upgrade
RUN pip3 install --no-cache-dir --no-build-isolation pymediainfo==6.0.1
RUN apt-get update && apt-get install -y ffmpeg
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
