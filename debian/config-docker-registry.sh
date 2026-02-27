#!/bin/bash
# ============================================================================
# config-docker-registry.sh - 配置 Docker 镜像加速
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "配置 Docker 镜像加速..."

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://hub-mirror.c.163.com/",
        "https://docker.mirrors.ustc.edu.cn/",
        "https://mirror.baidubce.com"
    ]
}
EOF

systemctl daemon-reload
systemctl restart docker

log_info "✅ Docker 镜像加速配置完成"
