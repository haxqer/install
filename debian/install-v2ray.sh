#!/bin/bash
# ============================================================================
# install-v2ray.sh - 安装 V2Ray
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 V2Ray..."
apt update -y && apt install -y curl

bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

log_info "✅ V2Ray 安装完成"
