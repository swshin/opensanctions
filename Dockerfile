FROM alephdata/memorious
COPY . /opensanctions
RUN cat /proc/version
RUN python3 --version
RUN apk add postgresql-dev gcc g++ python3-dev 
#RUN apk add postgresql-dev=10.7-r0 gcc g++ python3-dev=3.6.6-r0
RUN pip3 install -e /opensanctions
ENV ARCHIVE_PATH=/data/archive
ENV BACKEND = 'LEVELDB'
ENV MEMORIOUS_CONFIG_PATH=/opensanctions/opensanctions/config
