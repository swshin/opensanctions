FROM alephdata/opensanctions
COPY . /opensanctions
RUN pip3 install -e /opensanctions
ENV ARCHIVE_PATH=/data/archive \
    MEMORIOUS_CONFIG_PATH=/opensanctions/opensanctions/config

RUN touch /etc/periodic/daily/memorious
RUN chmod a+x /etc/periodic/daily/memorious
RUN echo "#!/bin/sh" > /etc/periodic/daily/memorious
RUN echo "memorious scheduled" >> /etc/periodic/daily/memorious

RUN memorious scheduled
CMD ["memorious", "process"]
