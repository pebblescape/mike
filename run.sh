#!/bin/bash

docker run -i -t -e DBNAME=docker -e DBUSER=docker -e DBPASS=docker -e PORT=5000 -e WORKERS=3 --link mike-redis:redis --link mike-postgresql:db pebbles/mike start