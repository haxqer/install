#!/bin/bash
# ============================================================================
# install-desktop-tools.sh - 安装远程桌面工具
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装远程桌面工具..."
apt update -y && apt install -y \
    xrdp \
    tigervnc-standalone-server \
    openssh-server

log_info "✅ 远程桌面工具安装完成"
