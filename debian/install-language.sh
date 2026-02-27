#!/bin/bash
# ============================================================================
# install-language.sh - 安装语言包和字体
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装语言包和字体..."
apt update -y && \
    apt install -y fonts-noto-color-emoji

log_info "配置 locale (请在交互界面中选择所需语言)..."
dpkg-reconfigure locales
locale -a
