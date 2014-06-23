#!/bin/bash

cd /vagrant/app

echo "-----> Starting redis & postgresql for asset precompile"
docker start mike-redis mike-postgresql > /dev/null

echo "-----> Building Mike image"
id=$(git archive master | docker run -d -e DBNAME=docker -e DBUSER=docker -e DBPASS=docker --link mike-redis:redis --link mike-postgresql:db -v /tmp/app-cache:/tmp/cache:rw -a stdin pebbles/pebblerunner build)
docker attach $id
test $(docker wait $id) -eq 0
docker commit $id pebbles/mike > /dev/null

echo "-----> Pushing Mike image"
# docker push pebbles/mike

echo "-----> Cleanup"
docker rm $id
