#!/bin/bash
# ============================================================================
# install-trojan-without-docker.sh - 安装 Trojan (非 Docker 方式)
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 Trojan..."
bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"

log_info "✅ Trojan 安装完成"
log_info "配置文件: /usr/local/etc/trojan/config.json"
