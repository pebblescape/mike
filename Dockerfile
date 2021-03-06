FROM pebbles/pebblerunner
MAINTAINER krisrang "mail@rang.ee"

ENV PORT 5000
ENV CURL_TIMEOUT 600
ENV DATABASE_URL postgres://user:pass@127.0.0.1/dbname
ENV REDIS_URL redis://localhost:6379

RUN echo '* * * * * . /etc/envvars; /scripts/run run bundle exec rake cron:minute > /dev/null\n\
*/10 * * * * . /etc/envvars; /scripts/run run bundle exec rake cron:tenminutes > /dev/null\n\
@hourly . /etc/envvars; /scripts/run run bundle exec rake cron:hour > /dev/null\n\
@daily . /etc/envvars; /scripts/run run bundle exec rake cron:day > /dev/null' | crontab -i -

COPY . /archive
RUN cd /archive && tar -c . | /scripts/run build
RUN rm -rf /archive
RUN ln -sf /etc/services-available/cron /etc/service
RUN ln -sf /etc/services-available/app-web /etc/service
RUN ln -sf /etc/services-available/app-worker /etc/service

EXPOSE 5000
