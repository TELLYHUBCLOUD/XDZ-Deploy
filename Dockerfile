FROM silentdemonsd/wzmlx:hk

WORKDIR /usr/src/app

RUN chmod 777 /usr/src/app

RUN apt-get update && \
    apt-get install -y python3-dev ffmpeg

# Upgrade pip tools properly
RUN python3 -m pip install --upgrade pip setuptools wheel setuptools_scm

# Install pymediainfo
RUN pip3 install --no-cache-dir --no-build-isolation pymediainfo==6.0.1

COPY requirements.txt .

# Safer install
RUN pip3 install --no-cache-dir --use-deprecated=legacy-resolver -r requirements.txt

COPY . .

CMD ["bash", "start.sh"]
