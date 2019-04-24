FROM alephdata/opensanctions
COPY . /opensanctions
RUN pip3 install -e /opensanctions
ENV ARCHIVE_PATH=/data/archive \
    MEMORIOUS_CONFIG_PATH=/opensanctions/opensanctions/config 
