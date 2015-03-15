FROM pebbles/pebblerunner
MAINTAINER krisrang "mail@rang.ee"

ENV PORT 5000
ENV CURL_TIMEOUT 600
ENV DATABASE_URL postgres://user:pass@127.0.0.1/dbname
ENV REDIS_URL redis://localhost:6379

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY . /archive
RUN cd /archive && tar -c . | /scripts/run build
RUN rm -rf /archive

# RUN echo '* * * * * /scripts/run run bundle exec rake cron:minute' | crontab -i -
RUN git clone https://github.com/pebblescape/dashboard.git /dashboard
RUN chown -R app:app /dashboard
RUN rm -r /app/public
RUN ln -sf /dashboard/build /app/public

EXPOSE 5000
ENTRYPOINT ["/usr/bin/supervisord"]
