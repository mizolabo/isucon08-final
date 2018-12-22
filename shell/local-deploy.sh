#!/bin/sh

set -eu

# docker
echo 'docker-compose start...'
docker-compose -f /home/vagrant/isucon08-final/webapp/docker-compose.yml -f /home/vagrant/isucon08-final/webapp/docker-compose.go.yml down
# docker-compose -f /home/vagrant/isucon08-final/webapp/docker-compose.yml -f /home/vagrant/isucon08-final/webapp/docker-compose.go.yml build
docker-compose -f /home/vagrant/isucon08-final/webapp/docker-compose.yml -f /home/vagrant/isucon08-final/webapp/docker-compose.go.yml up -d
echo 'docker-compose end...'


# echo 'bench make start...'
# cd /home/vagrant/isucon08-final/bench
# export DEPNOLOCK=1
# make init
# make deps
# make build
# echo 'bench make end...'

echo 'deploy finish!!!'
