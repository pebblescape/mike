#!/bin/bash

docker rm -f mike-build > /dev/null
git archive master | docker run -i -a stdin --name mike-build -e CURL_TIMEOUT=600 -e DATABASE_URL=postgres://user:pass@127.0.0.1/dbname -e REDIS_URL=redis://localhost:6379 pebbles/pebblerunner build > /dev/null
docker logs -f mike-build
docker commit mike-build pebbles/mike
docker rm mike-build
