FROM pebbles/cedarish
MAINTAINER krisrang "mail@rang.ee"

ADD . /app
ENV PORT 5000
ENV RAILS_ENV production
ENV WORKERS 3
EXPOSE 5000
WORKDIR /app
ENTRYPOINT ["/app/run.sh"]
