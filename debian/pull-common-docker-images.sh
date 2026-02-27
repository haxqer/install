#!/bin/bash
# ============================================================================
# pull-common-docker-images.sh - 拉取常用 Docker 镜像并推送到私有仓库
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

# 修改为你的私有仓库地址
harborDomain="harbor.haxqer.com/storage"

docker login "${harborDomain}"

# DockerHub 常用镜像
commonImages="ubuntu postgres redis traefik node alpine mysql python busybox nginx openjdk mongo golang mariadb rabbitmq debian sonarqube influxdb elasticsearch haproxy caddy kibana sentry chronograf adminer rust mysql:5.7 traefik:1.7-alpine elasticsearch:7.17.1"

log_info "拉取 DockerHub 常用镜像..."
echo "${commonImages}" | xargs -n 1 | xargs -I@ -P 5 docker pull @

log_info "标记镜像..."
echo "${commonImages}" | xargs -n 1 | xargs -I@ docker tag @ "${harborDomain}/"@

log_info "推送镜像到 ${harborDomain}..."
echo "${commonImages}" | xargs -n 1 | xargs -I@ -P 5 docker push "${harborDomain}/"@

# 第三方镜像
otherImages="nsqio/nsq:latest quay.io/coreos/etcd:latest quay.io/coreos/etcd:v2.3.8"

log_info "拉取第三方镜像..."
echo "${otherImages}" | xargs -n 1 | xargs -I@ -P 5 docker pull @

log_info "标记并推送第三方镜像..."
export harborDomain=${harborDomain}
echo "${otherImages}" | xargs -n 1 | perl -ne '$s = $1 if /([0-9a-zA-Z\:\/._\-]*)/s; print "docker tag $s $ENV{harborDomain}/$1:$2\n" if /\/([0-9a-zA-Z_\-]+)\:([0-9a-zA-Z._\-]+)$/s' | bash -
echo "${otherImages}" | xargs -n 1 | perl -ne 'print "docker push $ENV{harborDomain}/$1:$2\n" if /\/([0-9a-zA-Z_\-]+)\:([0-9a-zA-Z._\-]+)$/s' | bash -

log_info "✅ 镜像同步完成"