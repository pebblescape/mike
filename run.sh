#!/bin/bash

docker run --rm -i -t -e DBNAME=docker -e DBUSER=docker -e DBPASS=docker -e PORT=5000 -e WORKERS=3 -p 5000:5000 --link mike-redis:redis --link mike-postgresql:db pebbles/mike start