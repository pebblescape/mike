FROM pebbles/pebblerunner
MAINTAINER krisrang "mail@rang.ee"

ENV PORT 5000
ENV CURL_TIMEOUT 600
ENV DATABASE_URL postgres://user:pass@127.0.0.1/dbname
ENV REDIS_URL redis://localhost:6379

COPY . /archive
RUN cd /archive && tar -c . | /scripts/run build
RUN rm -rf /archive

RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5000
ENTRYPOINT ["/usr/bin/supervisord"]