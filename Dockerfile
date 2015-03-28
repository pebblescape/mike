FROM pebbles/pebblerunner
MAINTAINER krisrang "mail@rang.ee"

ENV PORT 5000
ENV CURL_TIMEOUT 600
ENV DATABASE_URL postgres://user:pass@127.0.0.1/dbname
ENV REDIS_URL redis://localhost:6379

COPY docker/boot /scripts/boot
COPY . /archive
RUN cd /archive && tar -c . | /scripts/run build
RUN rm -rf /archive
RUN ln -sf /etc/services-available/app-web /etc/service
RUN ln -sf /etc/services-available/app-worker /etc/service
RUN echo '* * * * * . /etc/envvars; /scripts/run run bundle exec rake cron:minute > /cronerror' | crontab -i -
RUN echo '*/10 * * * * . /etc/envvars; /scripts/run run bundle exec rake cron:tenminutes > /cronerror' | crontab -i -
RUN echo '@hourly . /etc/envvars; /scripts/run run bundle exec rake cron:hour > /cronerror' | crontab -i -
RUN echo '@daily . /etc/envvars; /scripts/run run bundle exec rake cron:day > /cronerror' | crontab -i -

RUN rm -r /app/public
RUN mkdir /dashboard
RUN chown -R app:app /dashboard
RUN chpst -u app -U app git clone https://github.com/pebblescape/dashboard.git --branch build --depth 1 /dashboard
RUN chpst -u app -U app ln -sf /dashboard/build /app/public

EXPOSE 5000
