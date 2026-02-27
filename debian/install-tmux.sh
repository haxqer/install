#!/bin/bash
# ============================================================================
# install-tmux.sh - 安装 tmux + oh-my-tmux 配置
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 tmux..."
apt update -y && apt install -y tmux xclip curl

log_info "正在下载 oh-my-tmux 配置..."
curl -o ~/.tmux.conf https://raw.githubusercontent.com/gpakosz/.tmux/master/.tmux.conf -L
curl -o ~/.tmux.conf.local https://raw.githubusercontent.com/gpakosz/.tmux/master/.tmux.conf.local -L

log_info "✅ tmux 安装完成"
