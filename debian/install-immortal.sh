#!/bin/bash
# ============================================================================
# install-immortal.sh - 安装 immortal 进程管理器
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 immortal..."
curl -s https://packagecloud.io/install/repositories/immortal/immortal/script.deb.sh | bash && \
    apt install -y immortal

log_info "✅ immortal 安装完成"
