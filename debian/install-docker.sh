#!/bin/bash
# ============================================================================
# install-docker.sh - 安装 Docker CE (含 docker compose 插件)
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

if command_exists docker; then
    log_warn "Docker 已安装: $(docker --version)"
    log_warn "如需重新安装，请先卸载"
    exit 0
fi

log_info "正在安装 Docker CE..."

apt-get update -y \
&& apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
&& mkdir -m 0755 -p /etc/apt/keyrings \
&& curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
&& chmod a+r /etc/apt/keyrings/docker.gpg \
&& echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
&& apt-get update -y \
&& apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_info "验证 Docker 安装..."
docker run hello-world

log_info "✅ Docker 安装完成: $(docker --version)"
log_info "   docker compose 版本: $(docker compose version)"
