#!/bin/bash

docker start mike-redis mike-postgresql > /dev/null
cd app
tar c . | docker run --link mike-redis:redis --link mike-postgresql:db -v /tmp/app-cache:/tmp/cache:rw -i -a stdin -a stdout pebbles/slugbuilder
# id=$(tar c . | docker run -v /tmp/app-cache:/tmp/cache:rw -i -a stdin pebbles/slugbuilder)
# docker wait $id
# docker cp $id:/tmp/slug.tgz .