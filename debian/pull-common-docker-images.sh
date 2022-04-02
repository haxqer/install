#!/bin/bash

# change it to your registry
harborDomain="harbor.haxqer.com/storage"

docker login "${harborDomain}"

# # images of DockerHub
commonImages="ubuntu postgres redis traefik node alpine mysql python busybox nginx openjdk mongo golang mariadb rabbitmq debian sonarqube influxdb elasticsearch haproxy caddy kibana sentry chronograf adminer rust mysql:5.7 traefik:1.7-alpine elasticsearch:7.17.1"

# pull images
echo "${commonImages}" | xargs -n 1 | xargs -I@ -P 5 docker pull @
# set images alias
echo "${commonImages}" | xargs -n 1 | xargs -I@ docker tag @ "${harborDomain}/"@
# push images
echo "${commonImages}" | xargs -n 1 | xargs -I@ -P 5 docker push "${harborDomain}/"@

# # images of third-party
otherImages="nsqio/nsq:latest quay.io/coreos/etcd:latest quay.io/coreos/etcd:v2.3.8"
# pull images
echo "${otherImages}" | xargs -n 1 | xargs -I@ -P 5 docker pull @
# set images alias
export harborDomain=${harborDomain}
echo "${otherImages}" | xargs -n 1 | perl -ne '$s = $1 if /([0-9a-zA-Z\:\/._\-]*)/s; print "docker tag $s $ENV{harborDomain}/$1:$2\n" if /\/([0-9a-zA-Z_\-]+)\:([0-9a-zA-Z._\-]+)$/s' | bash -
# push images
echo "${otherImages}" | xargs -n 1 | perl -ne 'print "docker push $ENV{harborDomain}/$1:$2\n" if /\/([0-9a-zA-Z_\-]+)\:([0-9a-zA-Z._\-]+)$/s' | bash -

# # untag
#docker images | grep "${harborDomain}" | perl -ne 'print "$1:$2\n" if /([^ ]*) *([^ ]*)/s' | xargs -I@ docker rmi @