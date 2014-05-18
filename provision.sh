#!/bin/bash

USER_DIR=/home/pebbles
APP_DIR=/home/pebbles/mike

if [ -e "/etc/.provisioned" ] ; then
  echo "VM already provisioned.  Remove /etc/.provisioned to force"
  exit 0
fi

cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

apt-get -qq update
DEBIAN_FRONTEND=noninteractive apt-get -qq install -y python-software-properties git-core linux-image-extra-`uname -r` lxc wget libxml2-dev
echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
echo deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main > /etc/apt/sources.list.d/ruby.list
apt-get -qq update
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes lxc-docker ruby2.1
service docker restart

useradd -d $USER_DIR -G sudo,docker -U pebbles
usermod -a -G docker vagrant

mkdir -p $USER_DIR/data
mkdir -p $APP_DIR
chown -R pebbles:pebbles $APP_DIR

docker run -d --name mike-redis -v /home/pebbles/data/redis:/var/lib/redis pebbles/redis
docker run -d --name mike-postgresql -v /home/pebbles/data/postgres:/data/main pebbles/postgresql

touch /etc/.provisioned
