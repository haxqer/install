#!/bin/bash
# ============================================================================
# install-china-docker.sh - 安装 Docker CE (中国镜像源)
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

if command_exists docker; then
    log_warn "Docker 已安装: $(docker --version)"
    exit 0
fi

log_info "正在通过阿里云镜像安装 Docker CE..."

apt-get update -y \
&& apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
&& mkdir -m 0755 -p /etc/apt/keyrings \
&& curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
&& chmod a+r /etc/apt/keyrings/docker.gpg \
&& echo \
    "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
&& apt-get update -y \
&& apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_info "✅ Docker 安装完成: $(docker --version)"
