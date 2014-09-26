#!/bin/bash

cd /vagrant/app

docker rm -f mike-build > /dev/null

echo "-----> Starting redis & postgresql for asset precompile"
docker start mike-redis mike-postgresql > /dev/null

echo "-----> Building Mike image"
git archive master | docker run -i -a stdin -a stdout --name mike-build -e DBNAME=docker -e DBUSER=docker -e DBPASS=docker --link mike-redis:redis --link mike-postgresql:db pebbles/pebblerunner build
docker commit mike-build pebbles/mike

echo "-----> Pushing Mike image"
docker push pebbles/mike

echo "-----> Cleanup"
docker rm mike-build
