#!/bin/sh

set -eu

echo 'deploy start!!!' | /home/ec2-user/isucon08-final/shell/slack.sh 

# git
cd /home/ec2-user/isucon08-final
echo 'git pull start...' | /home/ec2-user/isucon08-final/shell/slack.sh 
git pull
echo 'git pull end...' | /home/ec2-user/isucon08-final/shell/slack.sh 

# docker
echo 'docker-compose start...' | /home/ec2-user/isucon08-final/shell/slack.sh 
docker-compose -f /home/ec2-user/isucon08-final/webapp/docker-compose.yml -f /home/ec2-user/isucon08-final/webapp/docker-compose.go.yml down
# docker-compose -f /home/ec2-user/isucon08-final/webapp/docker-compose.yml -f /home/ec2-user/isucon08-final/webapp/docker-compose.go.yml build
docker-compose -f /home/ec2-user/isucon08-final/webapp/docker-compose.yml -f /home/ec2-user/isucon08-final/webapp/docker-compose.go.yml up -d
echo 'docker-compose end...' | /home/ec2-user/isucon08-final/shell/slack.sh 


echo 'bench make start...' | /home/ec2-user/isucon08-final/shell/slack.sh
cd /home/ec2-user/isucon08-final/bench
make init
make deps
make build
echo 'bench make end...' | /home/ec2-user/isucon08-final/shell/slack.sh 

echo 'deploy finish!!!' | /home/ec2-user/isucon08-final/shell/slack.sh 