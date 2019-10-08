#!/usr/bin/env sh

# Requires:
# curl
# jq

docker_version=`curl -s --unix-socket /var/run/docker.sock http://localhost/info | jq .ServerVersion`
echo "Docker version: ${docker_version}"

exit 0

## get list of nodes in cluster



### for each node

#### check tcp 2377
#### check tcp+udp 7946
#### check udp 4789
