#!/bin/bash
# ============================================================================
# install-netspeed.sh - 安装 TCP 加速脚本
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在下载 TCP 加速脚本..."
wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" \
    && chmod +x tcp.sh \
    && ./tcp.sh
